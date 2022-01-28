/*
 * Copyright 2020, 2022 ZUP IT SERVICOS EM TECNOLOGIA E INOVACAO SA
 * 
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 * 
 *     http://www.apache.org/licenses/LICENSE-2.0
 * 
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import { IdentifiableBeagleUIElement } from '@zup-it/beagle-web'

type Iteratee<ItemType, ReturnType> = (item: ItemType, parent: ItemType | null) => ReturnType

function forEachFromBottomLeft(
  node: IdentifiableBeagleUIElement,
  parent: IdentifiableBeagleUIElement | null,
  iteratee: Iteratee<IdentifiableBeagleUIElement, void>,
) {
  node.children?.forEach(child => forEachFromBottomLeft(child, node, iteratee))
  iteratee(node, parent)
}

function fixAbsolutePositionsForRoot(tree: IdentifiableBeagleUIElement) {
  // if the position is not absolute or if it's already a stack, nothing must be done
  if (tree.style?.positionType?.toLowerCase() !== 'absolute' || tree.style?.isStack) return
  // we can't replace the root node, so let's copy it to a child, erase it and transform into a container
  const child = {...tree}
  Object.keys(tree).forEach(k => delete tree[k])
  tree._beagleComponent_ = 'beagle:container'
  tree.id = `${child.id}_auto_root_`
  tree.children = [child]
}

function fixAbsolutePositionsForNode(node: IdentifiableBeagleUIElement) {
  // ignore this node if it has been previously identified as a stack
  if (node.style?.isStack) return
  const grouped: { stack: IdentifiableBeagleUIElement[], flex: IdentifiableBeagleUIElement[] } = { stack: [], flex: [] }
  node.children?.forEach((child) => {
    if (child.style?.positionType?.toLowerCase() === 'absolute') grouped.stack.push(child)
    else grouped.flex.push(child)
  })
  // if no child is absolute positioned, skip this node, change nothing
  if (grouped.stack.length === 0) return
  // otherwise, transform this node into a stack
  node.style ??= {}
  node.style.isStack = true
  // if no child is flexible, i.e. all are absolute positioned
  if (grouped.flex.length === 0) {
    // if flex.flex of the stack is 0, set to 1. It should calculate sizes and positions according to all the space available
    node.style.flex ??= {}
    node.style.flex.flex = node.style.flex.flex || 1
    // and we're done
    return
  }
  // otherwise, if the children is a mix of flexible and absolute nodes
  // then we must encapsulate all flexible nodes inside a flex container
  const flexContainer: IdentifiableBeagleUIElement = {
    _beagleComponent_: 'beagle:container',
    id: `${node.id}_auto_flex_`,
    // flex.flex must be undefined because this will go inside a Stack and not a Flex
    style: { flex: { ...node.style?.flex, flex: undefined } },
    children: grouped.flex,
  }
  node.children = [flexContainer, ...grouped.stack]
  return
}

const hasExpandedChild = (node: IdentifiableBeagleUIElement, expandedComponentsMap: Record<string, boolean>) => (
  node.children?.reduce(
    (result, child) => result || child.style?.flex?.flex || expandedComponentsMap[child._beagleComponent_.toLowerCase()],
    false,
  )
)

const isBoundedInFlexDirection = (node: IdentifiableBeagleUIElement, parent: IdentifiableBeagleUIElement | null) => (
  node.style?.flex?.flex
  || (parent?.style?.flex?.flexDirection == 'ROW' && node.style?.size?.width)
  || (parent?.style?.flex?.flexDirection != 'ROW' && node.style?.size?.height)
)

/* In Flutter we can't have a tree where a parent is a Flex with a flex factor (style.flex.flex) of zero and a child is a Flex with a Flex factor
greater than zero. In most of these cases, the parent flex will have an unrestricted height and Flutter won't know how to expand the child. Notice
that no flex factor is the same of flex factor 0. To fix this, whenever we find this scenario, we must set the flex factor of the parent to 1. */
function fixFlexFactors(
  node: IdentifiableBeagleUIElement,
  parent: IdentifiableBeagleUIElement | null,
  expandedComponentsMap: Record<string, boolean>,
) {
  const shouldForceFlex1 = !isBoundedInFlexDirection(node, parent) && hasExpandedChild(node, expandedComponentsMap)
  if (shouldForceFlex1) {
    node.style ??= {}
    node.style.flex ??= {}
    node.style.flex.flex = 1
  }
}

export function manageStyles(tree: IdentifiableBeagleUIElement, expandedComponentsMap: Record<string, boolean>) {
  fixAbsolutePositionsForRoot(tree)
  forEachFromBottomLeft(tree, null, (node, parent) => {
    fixAbsolutePositionsForNode(node)
    fixFlexFactors(node, parent, expandedComponentsMap)
  })
}
