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
