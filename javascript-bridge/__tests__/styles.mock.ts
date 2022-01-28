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

export const createAbsoluteRoot: () => IdentifiableBeagleUIElement = () => ({
  "_beagleComponent_": "beagle:container",
  "id": "root",
  "style": {
    "position": {
      "top": {
        "value": 100,
        "type": "REAL"
      },
    },
    "size": {
      "width": {
        "value": 100,
        "type": "REAL"
      },
      "height": {
        "value": 100,
        "type": "REAL"
      }
    },
    "backgroundColor": "red",
    "positionType": "ABSOLUTE",
  }
})

export const createOneAbsoluteOneFlexTree: () => IdentifiableBeagleUIElement = () => ({
  "_beagleComponent_": "beagle:container",
  "id": "rootContainer",
  "children": [
    {
      "_beagleComponent_": "beagle:container",
      "id": "absoluteSquare",
      "style": {
        "position": {
          "top": {
            "value": 100,
            "type": "REAL"
          },
        },
        "size": {
          "width": {
            "value": 100,
            "type": "REAL"
          },
          "height": {
            "value": 100,
            "type": "REAL"
          }
        },
        "backgroundColor": "red",
        "positionType": "ABSOLUTE",
      }
    },
    {
      "_beagleComponent_": "beagle:container",
      "id": "flexColumn",
      "children": [
        { "_beagleComponent_": "beagle:text", "text": "TEXT 1", "id": "text1" },
        { "_beagleComponent_": "beagle:text", "text": "TEXT 2", "id": "text2" },
        { "_beagleComponent_": "beagle:text", "text": "TEXT 3", "id": "text3" },
      ]
    }
  ]
})

export const createFlexTreeWithExpandedChild: () => IdentifiableBeagleUIElement = () => ({
  "_beagleComponent_": "beagle:container",
  "id": "rootContainer",
  "children": [
    {
      "_beagleComponent_": "beagle:container",
      "id": "autoSize"
    },
    {
      "_beagleComponent_": "beagle:container",
      "id": "expanded",
      "style": {
        "flex": {
          "flex": 1
        }
      }
    },
  ]
})

export const createMultiLevelFlexTreeWithExpandedChild: () => IdentifiableBeagleUIElement = () => ({
  "_beagleComponent_": "beagle:container",
  "id": "rootContainer",
  "children": [
    {
      "_beagleComponent_": "beagle:container",
      "id": "firstChild",
      "children": [
        {
          "_beagleComponent_": "beagle:container",
          "id": "firstChildExpanded",
          "style": {
            "flex": {
              "flex": 1
            }
          }
        }
      ]
    },
    {
      "_beagleComponent_": "beagle:container",
      "id": "secondChild",
      "children": [
        {
          "_beagleComponent_": "beagle:container",
          "id": "secondChildExpanded",
          "style": {
            "flex": {
              "flex": 1
            }
          }
        }
      ]
    },
  ]
})

export const createMultiLevelFlexTreeWithComponentExpandedByDefault: () => IdentifiableBeagleUIElement = () => ({
  "_beagleComponent_": "beagle:container",
  "id": "rootContainer",
  "children": [
    {
      "_beagleComponent_": "beagle:container",
      "id": "firstChild",
      "children": [
        {
          "_beagleComponent_": "beagle:container",
          "id": "firstChildExpanded",
        }
      ]
    },
    {
      "_beagleComponent_": "beagle:container",
      "id": "secondChild",
      "children": [
        {
          "_beagleComponent_": "beagle:scrollView",
          "id": "scrollView",
        }
      ]
    },
  ]
})

export const createFlexTreeWithoutExpandedChild: () => IdentifiableBeagleUIElement = () => ({
  "_beagleComponent_": "beagle:container",
  "id": "rootContainer",
  "children": [
    {
      "_beagleComponent_": "beagle:container",
      "id": "autoSize"
    }
  ]
})

export const createExpandedFlexTreeWithExpandedChild: () => IdentifiableBeagleUIElement = () => ({
  "_beagleComponent_": "beagle:container",
  "id": "rootContainer",
  "style": {
    "flex": {
      "flex": 0.5
    }
  },
  "children": [
    {
      "_beagleComponent_": "beagle:container",
      "id": "autoSize",
      "style": {
        "flex": {
          "flex": 1
        }
      }
    }
  ]
})

export const createColumnWithBoundedHeightAndExpandedChild: () => IdentifiableBeagleUIElement = () => ({
  "_beagleComponent_": "beagle:container",
  "id": "parentContainer",
  "style": {
    "size": {
      "height": {
        "value": 100,
        "type": 'REAL'
      }
    }
  },
  "children": [
    {
      "_beagleComponent_": "beagle:container",
      "id": "autoSize",
      "style": {
        "flex": {
          "flex": 1
        }
      }
    }
  ]
})

export const createColumnWithBoundedWidthAndExpandedChild: () => IdentifiableBeagleUIElement = () => {
  const tree = createColumnWithBoundedHeightAndExpandedChild()
  tree.style!.size.width = tree.style!.size.height
  delete tree.style!.size.height
  return tree
}

export const createRowWithBoundedWidthAndExpandedChild: () => IdentifiableBeagleUIElement = () => ({
  "_beagleComponent_": "beagle:container",
  "id": "rowContainer",
  "style": {
    "flex": {
      "flexDirection": "ROW"
    }
  },
  children: [createColumnWithBoundedWidthAndExpandedChild()]
})

export const createRowWithBoundedHeightAndExpandedChild: () => IdentifiableBeagleUIElement = () => {
  const tree = createRowWithBoundedWidthAndExpandedChild()
  const parentContainer = tree.children![0]!
  parentContainer.style!.size.height = parentContainer.style!.size.width
  delete parentContainer.style!.size.width
  return tree
}

export const createFullExample: () => IdentifiableBeagleUIElement = () => ({
  "_beagleComponent_": "beagle:container",
  "id": "root",
  "children": [
    {
      "_beagleComponent_": "beagle:container",
      "id": "flexColors",
      "style": {
        "flex": {
          "flexDirection": "ROW"
        },
        "size": { "height": { "value": 20, "type": "REAL" } }
      },
      "children": [
        {
          "_beagleComponent_": "beagle:container",
          "id": "flexRed",
          "style": {
            "flex": {
              "flex": 0.2
            },
            "height": { "value": 20, "type": "REAL" },
            "backgroundColor": "#FF0000"
          }
        },
        {
          "_beagleComponent_": "beagle:container",
          "id": "flexGreen",
          "style": {
            "flex": {
              "flex": 0.3
            },
            "backgroundColor": "#00FF00"
          }
        },
        {
          "_beagleComponent_": "beagle:container",
          "id": "flexBlue",
          "style": {
            "flex": {
              "flex": 0.5
            },
            "backgroundColor": "#0000FF"
          }
        }
      ]
    },
  ]
})
