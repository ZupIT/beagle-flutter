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
import { manageStyles } from '../src/styles'
import {
  createAbsoluteRoot,
  createColumnWithBoundedHeightAndExpandedChild,
  createColumnWithBoundedWidthAndExpandedChild,
  createExpandedFlexTreeWithExpandedChild,
  createFlexTreeWithExpandedChild,
  createFlexTreeWithoutExpandedChild,
  createMultiLevelFlexTreeWithComponentExpandedByDefault,
  createMultiLevelFlexTreeWithExpandedChild,
  createOneAbsoluteOneFlexTree,
  createRowWithBoundedHeightAndExpandedChild,
  createRowWithBoundedWidthAndExpandedChild,
} from './styles.mock'

function expectOneAbsoluteOneFlexToBeRight(tree: IdentifiableBeagleUIElement) {
  expect(tree.id).toBe('rootContainer')
  expect(tree.children?.length).toBe(2)
  expect(tree.style?.isStack).toBe(true)

  const newFlexContainer = tree.children![0]!
  expect(newFlexContainer.id).toBe('rootContainer_auto_flex_')
  expect(newFlexContainer._beagleComponent_).toBe('beagle:container')
  expect(newFlexContainer.children?.length).toBe(1)

  const flexColumn = newFlexContainer.children![0]!
  expect(flexColumn.id).toBe('flexColumn')
  expect(flexColumn.children?.length).toBe(3)

  for(let i = 0; i < 3; i++) {
    expect(flexColumn.children![i]!.id).toBe(`text${i + 1}`)
    expect(flexColumn.children![i]!.children).toBeUndefined()
  }

  const absoluteSquare = tree.children![1]!
  expect(absoluteSquare.id).toBe('absoluteSquare')
  expect(absoluteSquare.children).toBeUndefined()
}

function expectAbsoluteRootToBeRight(tree: IdentifiableBeagleUIElement) {
  expect(tree.id).toBe('root_auto_root_')
  expect(tree.style).toEqual({ isStack: true, flex: { flex: 1 } })
  expect(tree._beagleComponent_).toBe('beagle:container')
  expect(tree.children?.length).toBe(1)
  expect(Object.keys(tree).length).toBe(4)

  expect(tree.children![0]!).toEqual(createAbsoluteRoot())
}

describe('styles', () => {
  describe('styles: absolute positioning', () => {
    describe('One absolute node and one flex node', () => {
      it('should create a new flex container and place single flex object inside', () => {
        const tree = createOneAbsoluteOneFlexTree()
        manageStyles(tree, {})
        expectOneAbsoluteOneFlexToBeRight(tree)
      })
    
      it('should not mess with the structure that has already been managed', () => {
        const tree = createOneAbsoluteOneFlexTree()
        manageStyles(tree, {})
        manageStyles(tree, {})
        expectOneAbsoluteOneFlexToBeRight(tree)
      })

      it('should not apply flex.flex = 1 to the root node', () => {
        const tree = createOneAbsoluteOneFlexTree()
        manageStyles(tree, {})
        expect(tree.style?.flex?.flex).toBeUndefined()
      })
    })

    describe('Absolute root node', () => {
      it('should wrap the tree under a bare container where style.isStack is true', () => {
        const tree = createAbsoluteRoot()
        manageStyles(tree, {})
        expectAbsoluteRootToBeRight(tree)
      })

      it('should not mess with the structure that has already been managed', () => {
        const tree = createAbsoluteRoot()
        manageStyles(tree, {})
        manageStyles(tree, {})
        expectAbsoluteRootToBeRight(tree)
      })
    })
  })

  describe('styles: flex factors', () => {
    it('should change flex factor', () => {
      const tree = createFlexTreeWithExpandedChild()
      manageStyles(tree, {})
      expect(tree.style?.flex?.flex).toBe(1)
    })

    it('should change flex factors on multi-level tree', () => {
      const tree = createMultiLevelFlexTreeWithExpandedChild()
      manageStyles(tree, {})
      expect(tree.style?.flex?.flex).toBe(1)
      expect(tree.children![0]!.style?.flex?.flex).toBe(1)
      expect(tree.children![1]!.style?.flex?.flex).toBe(1)
    })

    it('should change flex factor because component is expanded by default, despite what the flex factor says', () => {
      const tree = createMultiLevelFlexTreeWithComponentExpandedByDefault()
      manageStyles(tree, { 'beagle:scrollview': true })
      expect(tree.style?.flex?.flex).toBe(1)
      expect(tree.children![0]!.style?.flex?.flex).toBeUndefined()
      expect(tree.children![1]!.style?.flex?.flex).toBe(1)
    })

    it('should not change flex factors because no children expands', () => {
      const tree = createFlexTreeWithoutExpandedChild()
      manageStyles(tree, {})
      expect(tree.style?.flex?.flex).toBeUndefined()
    })

    it('should not change flex factors because factor has already been set', () => {
      const tree = createExpandedFlexTreeWithExpandedChild()
      manageStyles(tree, {})
      expect(tree.style?.flex?.flex).toBe(0.5)
    })

    it('should not change flex factor because height is defined in a column layout', () => {
      const tree = createColumnWithBoundedHeightAndExpandedChild()
      manageStyles(tree, {})
      expect(tree.style?.flex?.flex).toBeUndefined()
    })

    it('should not change flex factor because width is defined in a row layout', () => {
      const tree = createRowWithBoundedWidthAndExpandedChild()
      manageStyles(tree, {})
      expect(tree.style?.flex?.flex).toBeUndefined()
    })

    it('should change flex factor because, although width is defined, it\'s a column layout', () => {
      const tree = createColumnWithBoundedWidthAndExpandedChild()
      manageStyles(tree, {})
      expect(tree.style?.flex?.flex).toBe(1)
    })

    it('should not change flex factor because it is inside a row and not a column', () => {
      const tree = createRowWithBoundedHeightAndExpandedChild()
      manageStyles(tree, {})
      expect(tree.style?.flex?.flex).toBe(undefined)
    })
  })
})
