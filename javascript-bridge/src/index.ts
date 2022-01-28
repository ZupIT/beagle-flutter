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

import createBeagleService, {
  BeagleService,
  BeagleUIElement,
  DataContext,
  IdentifiableBeagleUIElement,
  logger,
  TemplateManager,
  TreeInsertionMode,
  Tree,
} from '@zup-it/beagle-web'
import { createCustomActionMap } from './action'
import { createBeagleView, getView } from './view'
import { callFunction } from './function'
import { httpClient, respondHttpRequest } from './http-client'
import { resolvePromise, rejectPromise } from './promise'
import { createCustomOperationMap } from './operation'
import logToFlutter from './utils/flutter-js-logger'
import { analytics } from './analytics'
import { cloneTemplate, doTreeFullRender, getContextEvaluatedTemplate, getTreeContextHierarchy, preProcessTemplateTree } from './render'
import { manageStyles } from './styles'

interface StartParams {
  baseUrl: string,
  actionKeys: string[],
  customOperations: string[],
  enableStyling: boolean,
  expandedComponentsMap: Record<string, boolean>,
}

// @ts-ignore
window.beagle = (() => {
  let service: BeagleService
  const analyticsProvider = analytics()
  //Calls here to initialize the config before the first events 
  analyticsProvider.getConfig()
  const api = {
    start: ({ actionKeys, customOperations, enableStyling, expandedComponentsMap, ...other }: StartParams) => {
      service = createBeagleService({
        components: {},
        disableCssTransformation: true,
        fetchData: httpClient.fetch,
        customActions: createCustomActionMap(actionKeys),
        customOperations: createCustomOperationMap(customOperations),
        analyticsProvider: analyticsProvider,
        platform: "flutter",
        lifecycles: enableStyling ? { beforeViewSnapshot: tree => manageStyles(tree, expandedComponentsMap) } : undefined,
        ...other,
      })
      
      logger.setCustomLogFunction(logToFlutter)
    },
    createBeagleView: () => createBeagleView(service),
    httpClient: { respond: respondHttpRequest },
    call: (id: string, argumentsMap?: Record<string, any>) => {
      console.log(`js: called function with id ${id} and argument map: ${JSON.stringify(argumentsMap)}`)
      callFunction(id, argumentsMap)
    },
    callViewFunction: (viewId: string, functionId: string, argumentsMap: Record<string, any>) => {
      const view = getView(viewId)
      if (view) view.executeFunction(functionId, argumentsMap)
    },
    getViewById: getView,
    getService: () => service,
    promise: {
      resolve: resolvePromise,
      reject: rejectPromise, 
    },
    render: {
      getTreeContextHierarchy: (viewId: string) => JSON.stringify(getTreeContextHierarchy(viewId)),
      getContextEvaluatedTemplate: (viewId: string, context: DataContext[], templateManager: TemplateManager) => 
        JSON.stringify(getContextEvaluatedTemplate(viewId, context, templateManager, service)),
      cloneTemplate: (template: BeagleUIElement) => JSON.stringify(cloneTemplate(template)),
      preProcessTemplateTree: (viewTree: BeagleUIElement) => JSON.stringify(preProcessTemplateTree(viewTree, service)),
      doTreeFullRender: (viewId: string, anchorId: string, children: IdentifiableBeagleUIElement[], mode: TreeInsertionMode = 'replace') => 
        doTreeFullRender(viewId, anchorId, children, mode),
    },
  }

  return api
})()
