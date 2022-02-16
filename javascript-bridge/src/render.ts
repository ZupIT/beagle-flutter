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

import { BeagleService, BeagleUIElement, Component, DataContext, IdentifiableBeagleUIElement, TemplateManager, Tree, TreeInsertionMode } from '@zup-it/beagle-web'
import Context from '@zup-it/beagle-web/beagle-view/render/context'
import { getEvaluatedTemplate } from '@zup-it/beagle-web/beagle-view/render/template-manager'
import { getView } from './view'

export function getTreeContextHierarchy(viewId: string) {  
  const view = getView(viewId)
  const uiTree = JSON.parse(view.getTreeAsJson()) as IdentifiableBeagleUIElement
  const globalContexts = [view.getBeagleService().globalContext.getAsDataContext()]
  const hierarchy = Context.evaluate(uiTree, globalContexts, false)
  return Object.keys(hierarchy).map(key => hierarchy[key]).reduce((prev, cur) => [...prev, ...cur], [])
}

export function getContextEvaluatedTemplate(viewId: string, context: DataContext[], templateManager: TemplateManager, service: BeagleService) {
  const contextHierarchy = [...context || [], ...getTreeContextHierarchy(viewId)]
  return getEvaluatedTemplate(templateManager, contextHierarchy, service.operationHandlers)
}

export function cloneTemplate(template: BeagleUIElement) {
  return Tree.clone(template) as IdentifiableBeagleUIElement
}

export function preProcessTemplateTree(viewTree: BeagleUIElement, service: BeagleService) {
  Tree.forEach(viewTree, (component) => {
    Component.formatChildrenProperty(component, service.childrenMetadata[component._beagleComponent_])
    Component.assignId(component)
    Component.eraseNullProperties(component)
  })    
  return viewTree as IdentifiableBeagleUIElement
}

export function doTreeFullRender(viewId: string, anchorId: string, children: IdentifiableBeagleUIElement[], mode: TreeInsertionMode = 'replace') {
  const view = getView(viewId)
  const uiTree = view.getTree()
  const anchorElement = Tree.findById(uiTree, anchorId)
  
  if (anchorElement) {
    const insertion = {
      prepend: (children: IdentifiableBeagleUIElement[]) => [...children?.reverse() || [], ...anchorElement.children || []],
      append: (children: IdentifiableBeagleUIElement[]) => [...anchorElement.children || [], ...children || []],
      replace: (children: IdentifiableBeagleUIElement[]) => children || [],
    }

    anchorElement.children = insertion[mode] ? insertion[mode](children) : insertion.replace(children)
    view.getRenderer().doFullRender(anchorElement, anchorId)
  }        
}
