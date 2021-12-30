/*
 * Copyright 2020 ZUP IT SERVICOS EM TECNOLOGIA E INOVACAO SA
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

import 'package:beagle/beagle.dart';

final simpleScreen = BeagleUIElement({
  "_beagleComponent_" : "beagle:screenComponent",
  "child": {
    "_beagleComponent_" : "beagle:text",
    "text": "Hello World"
  }
});

final simpleScrollView = BeagleUIElement({
  "_beagleComponent_" : "beagle:screenComponent",
  "children": [{
    "_beagleComponent_": "beagle:scrollView",
    "children": [{
      "_beagleComponent_": "beagle:text",
      "text": "q\nw\ne\nr\nt\ny\nu\ni\no\np\na\ns\nd\nf\ng\nh\nj\nk\nl\nç\nz\nx\nc\nv\nb\nn\nm"
    }]
  }]
});

final internalFlex1 = BeagleUIElement({
  "_beagleComponent_" : "beagle:container",
  "children" : [{
    "_beagleComponent_" : "beagle:text",
    "text": "Hi",
    "style": {
      "flex": { "flex": 1 },
      "margin": {
        "top": {
          "value": 100,
          "type": "REAL"
        }
      }
    }
  }],
});

final pageView = BeagleUIElement({
  "_beagleComponent_" : "beagle:screenComponent",
  "child" : {
    "_beagleComponent_" : "beagle:container",
    "children" : [ {
      "_beagleComponent_" : "beagle:button",
      "text" : "Go to Page 3",
      "onPress" : [ {
        "_beagleAction_" : "beagle:setContext",
        "contextId" : "context",
        "value" : 2
      } ]
    }, {
      "_beagleComponent_" : "beagle:pageView",
      "onPageChange" : [ {
        "_beagleAction_" : "beagle:setContext",
        "contextId" : "context",
        "value" : "@{onPageChange}"
      } ],
      "currentPage" : "@{context}"
    }],
    "context" : {
      "id" : "context",
      "value" : 0
    },
  }
});

final pullToRefresh = BeagleUIElement({
  "_beagleComponent_" : "beagle:screenComponent",
  "navigationBar" : {
    "title" : "Beagle PullToRefresh",
    "showBackButton" : true,
    "navigationBarItems" : const <dynamic>[]
  },
  "child" : {
    "_beagleComponent_" : "beagle:pullToRefresh",
    "context" : {
      "id" : "refreshContext",
      "value" : false
    },
    "onPull" : [ {
      "_beagleAction_" : "beagle:setContext",
      "contextId" : "refreshContext",
      "value" : true
    }, {
      "_beagleAction_" : "beagle:sendRequest",
      "url" : "/generate-string-lista",
      "method" : "GET",
      "onSuccess" : [{
        "_beagleAction_" : "beagle:setContext",
        "contextId" : "listContext",
        "value" : "@{onSuccess.data}"
      }],
      "onFinish": [{
        "_beagleAction_" : "beagle:setContext",
        "contextId" : "refreshContext",
        "value" : false
      }]
    } ],
    "isRefreshing" : "@{refreshContext}",
    "color" : "#0000FF",
    "child" : {
      "_beagleComponent_" : "beagle:text",
      "text" : "@{refreshContext}"
    }
  },
  "context" : {
    "id" : "listContext",
    "value" : [ "Pull", "to", "refresh", "list" ]
  }
});

final styleSimpleAbsolute = BeagleUIElement({
  "_beagleComponent_": "beagle:container",
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
});

final styleAbsoluteFlex = BeagleUIElement({
  "_beagleComponent_": "beagle:container",
  "id": "rootContainer",
  // "style": { "flex": { "flex": 1, "alignItems": "STRETCH" } },
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
        "backgroundColor": "#FF0000",
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
});

final styleAbsolutePositions = BeagleUIElement({
  "_beagleComponent_": "beagle:container",
  "style": {
    "margin": {
      "top": {
        "value": 100,
        "type": "REAL"
      }
    }
  },
  "children": [
    {
      "_beagleComponent_": "beagle:container",
      "style": {
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
        "backgroundColor": "#00FF00"
      }
    },
    {
      "_beagleComponent_": "beagle:container",
      "style": {
        "size": {
          "width": {
            "value": 150,
            "type": "REAL"
          },
          "height": {
            "value": 150,
            "type": "REAL"
          }
        },
        "backgroundColor": "#0000FF"
      }
    },
    {
      "_beagleComponent_": "beagle:container",
      "style": {
        "size": {
          "width": {
            "value": 50,
            "type": "REAL"
          },
          "height": {
            "value": 50,
            "type": "REAL"
          }
        },
        "positionType": "ABSOLUTE",
        "position": {
          "bottom": {
            "value": 20,
            "type": "REAL"
          },
          "left": {
            "value": 10,
            "type": "REAL"
          }
        },
        "backgroundColor": "#FF0000"
      }
    }
  ]
});

final stylePercentSizes = BeagleUIElement({
  "_beagleComponent_": "beagle:container",
  "style":{
    "size":{
      "width": {
        "value": 50,
        "type": "PERCENT"
      },
      "height": {
        "value": 50,
        "type": "PERCENT"
      },
    },
    "backgroundColor":"#FF0000"
  }
});

final stylePercentPaddings = BeagleUIElement({
  "_beagleComponent_": "beagle:container",
  "style": {
    "padding": {
      "all": {
        "value": 10,
        "type": "PERCENT"
      }
    },
    "margin": {
      "all": {
        "value": 20,
        "type": "REAL"
      }
    },
    "backgroundColor": "#FF0000"
  },
  "children": [
    {
      "_beagleComponent_": "beagle:container",
      "style": {
        "size": {
          "width": {
            "value": 50,
            "type": "REAL"
          },
          "height": {
            "value": 50,
            "type": "REAL"
          }
        },
        "backgroundColor": "#FFFFFF"
      }
    }
  ]
});

final styleDisplay = BeagleUIElement({
  "_beagleComponent_": "beagle:container",
  "style": {
    "flex": {
      "flexDirection": "COLUMN",
      "alignItems": "CENTER",
      "justifyContent": "CENTER",
      "flexWrap": "NO_WRAP"
    }
  },
  "context": {
    "id": "visible",
    "value": true
  },
  "children": [
    {
      "_beagleComponent_": "beagle:button",
      "text": "Toggle text visibility (@{visible})",
      "style": {
        "margin": {
          "all": {
            "value": 20,
            "type": "REAL"
          }
        }
      },
      "onPress": [{
        "_beagleAction_": "beagle:setContext",
        "contextId":"visible",
        "value": "@{not(visible)}"
      }]
    },
    {
      "_beagleComponent_": "beagle:text",
      "text": "bla bla bla bla\nqwgwqe qf qw wegwgwge\newqwet ewtwet wetqwte\nrweqtrewtqwtw",
      "style": {
        "display": "@{condition(visible, 'FLEX', 'NONE')}",
        "margin": {
          "vertical": {
            "value": 30,
            "type": "REAL"
          }
        }
      }
    },
    {
      "_beagleComponent_": "beagle:text",
      "text": "Always visible text",
      "alignment": "CENTER",
      "styleId": "title",
      "textColor": "#001B26"
    }
  ]
});

// tests most style properties
final styleFull = BeagleUIElement({
  "_beagleComponent_": "beagle:container",
  "children": [
    {
      "_beagleComponent_": "beagle:container",
      "style": {
        "flex": {
          "flexDirection": "ROW",
          "justifyContent": "SPACE_BETWEEN",
          "alignItems": "CENTER"
        },
        "margin": {
          "vertical": {
            "value": 40,
            "type": "REAL"
          }
        },
        "backgroundColor": "#000000"
      },
      "children": [
        {
          "_beagleComponent_": "beagle:container",
          "style": {
            "padding": {
              "all": {
                "value": 8,
                "type": "REAL"
              }
            },
            "backgroundColor": "#FF0000"
          },
          "children": [
            {
              "_beagleComponent_": "beagle:text",
              "text": "Hello"
            }
          ]
        },
        {
          "_beagleComponent_": "beagle:container",
          "style": {
            "size": {
              "height": {
                "value": 10,
                "type": "REAL"
              },
              "width": {
                "value": 10,
                "type": "REAL"
              }
            },
            "backgroundColor": "#FFFFFF",
            "cornerRadius": {
              "radius": 5
            }
          }
        },
        {
          "_beagleComponent_": "beagle:container",
          "style": {
            "padding": {
              "all": {
                "value": 8,
                "type": "REAL"
              }
            },
            "backgroundColor": "#00FF00"
          },
          "children": [
            {
              "_beagleComponent_": "beagle:text",
              "text": "Beautiful"
            }
          ]
        },
        {
          "_beagleComponent_": "beagle:container",
          "style": {
            "size": {
              "height": {
                "value": 10,
                "type": "REAL"
              },
              "width": {
                "value": 10,
                "type": "REAL"
              }
            },
            "backgroundColor": "#FFFFFF",
            "cornerRadius": {
              "radius": 5
            }
          }
        },
        {
          "_beagleComponent_": "beagle:container",
          "style": {
            "padding": {
              "all": {
                "value": 8,
                "type": "REAL"
              }
            },
            "backgroundColor": "#0000FF"
          },
          "children": [
            {
              "_beagleComponent_": "beagle:text",
              "text": "World!"
            }
          ]
        }
      ]
    },
    {
      "_beagleComponent_": "beagle:container",
      "style": {
        "flex": {
          "flexDirection": "ROW"
        },
        "size": { "height": { "value": 20, "type": "REAL" } }
      },
      "children": [
        {
          "_beagleComponent_": "beagle:container",
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
          "style": {
            "flex": {
              "flex": 0.3
            },
            "backgroundColor": "#00FF00"
          }
        },
        {
          "_beagleComponent_": "beagle:container",
          "style": {
            "flex": {
              "flex": 0.5
            },
            "backgroundColor": "#0000FF"
          }
        }
      ]
    },
    {
      "_beagleComponent_": "beagle:container",
      "style": {
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
        "backgroundColor": "#000000",
        "display": "NONE"
      }
    },
    {
      "_beagleComponent_": "beagle:container",
      "style": {
        "margin": {
          "top": {
            "value": 100,
            "type": "REAL"
          }
        }
      },
      "children": [
        {
          "_beagleComponent_": "beagle:container",
          "style": {
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
            "backgroundColor": "#00FF00"
          }
        },
        {
          "_beagleComponent_": "beagle:container",
          "style": {
            "size": {
              "width": {
                "value": 150,
                "type": "REAL"
              },
              "height": {
                "value": 150,
                "type": "REAL"
              }
            },
            "backgroundColor": "#0000FF"
          }
        },
        {
          "_beagleComponent_": "beagle:container",
          "style": {
            "size": {
              "width": {
                "value": 50,
                "type": "REAL"
              },
              "height": {
                "value": 50,
                "type": "REAL"
              }
            },
            "positionType": "ABSOLUTE",
            "position": {
              "bottom": {
                "value": 20,
                "type": "REAL"
              },
              "left": {
                "value": 10,
                "type": "REAL"
              }
            },
            "backgroundColor": "#FF0000"
          }
        }
      ]
    }
  ]
});

final contextUpdate = BeagleUIElement({
  "_beagleComponent_": "beagle:container",
  "child": {
    "_beagleComponent_": "beagle:button",
    "text": "count: @{ctx}",
    "context": {
      "id": "ctx",
      "value": 0,
    },
    "style": {
      "margin": {
        "top": {
          "value": 50,
          "type": "REAL"
        }
      }
    },
    "onPress": [{
      "_beagleAction_": "beagle:setContext",
      "id": "ctx",
      "value": "@{sum(ctx, 1)}"
    }]
  }
});

final sizedListView = BeagleUIElement({
  "_beagleComponent_": "beagle:container",
  "id": "sizedContainer",
  "style": {
    "size": {
      "height": {
        "value": 200,
        "type": "REAL"
      }
    }
  },
  "children": [
    {
      "_beagleComponent_": "beagle:listview",
      "id": "listView",
      "direction": "VERTICAL",
      "dataSource": [
        {
          "name": "Kelsier",
          "race": "Half-skaa",
          "planet": "Scadrial",
          "isMistborn": true,
          "age": 38,
          "sex": "male"
        },
        {
          "name": "Vin",
          "race": "Half-skaa",
          "planet": "Scadrial",
          "isMistborn": true,
          "age": 20,
          "sex": "female"
        },
        {
          "name": "TenSoon",
          "race": "Kandra",
          "planet": "Scadrial",
          "isMistborn": false,
          "age": 40,
          "sex": "male"
        }
      ],
      "templates": [
        {
          "view": {
            "_beagleComponent_": "beagle:container",
            "style": {
              "margin": {
                "bottom": {
                  "value": 20,
                  "type": "REAL"
                }
              }
            },
            "children": [
              {
                "_beagleComponent_": "beagle:text",
                "text": "Name: @{item.name}"
              },
              {
                "_beagleComponent_": "beagle:text",
                "text": "Race: @{item.race}"
              },
              {
                "_beagleComponent_": "beagle:text",
                "text": "Mistborn: @{item.isMistborn}"
              },
              {
                "_beagleComponent_": "beagle:text",
                "text": "Planet: @{item.planet}"
              },
              {
                "_beagleComponent_": "beagle:text",
                "text": "sex: @{item.sex}"
              },
              {
                "_beagleComponent_": "beagle:text",
                "text": "age: @{item.age}"
              }
            ]
          }
        }
      ]
    }
  ]
});

final pullToRefreshListView = BeagleUIElement({
  "_beagleComponent_": "beagle:pullToRefresh",
  "context": {
    "id": "isRefreshing",
    "value": false
  },
  "isRefreshing": "@{isRefreshing}",
  "onPull": [
    {
      "_beagleAction_": "beagle:setContext",
      "contextId": "isRefreshing",
      "value": true
    }
  ],
  "children": [
    {
      "_beagleComponent_": "beagle:listview",
      "id": "listView",
      "direction": "VERTICAL",
      "dataSource": [0, 1, 2, 3, 4, 5, 6, 7, 8, 9],
      "templates": [
        {
          "view": {
            "_beagleComponent_": "beagle:text",
            "text": "@{item}"
          }
        }
      ]
    }
  ]
});

final sizedGridView = BeagleUIElement({
  "_beagleComponent_": "beagle:container",
  "id": "sizedContainer",
  "style": {
    "size": {
      "height": {
        "value": 200,
        "type": "REAL"
      }
    }
  },
  "children": [
    {
      "_beagleComponent_": "beagle:gridview",
      "direction": "VERTICAL",
      "spanCount": 3,
      "dataSource": [0, 1, 2, 3, 4, 5, 6, 7, 8, 9],
      "templates": [
        {
          "view": {
            "_beagleComponent_": "beagle:text",
            "text": "@{item}"
          }
        }
      ]
    }
  ]
});

final pullToRefreshGridView = BeagleUIElement({
  "_beagleComponent_": "beagle:pullToRefresh",
  "context": {
    "id": "isRefreshing",
    "value": false
  },
  "isRefreshing": "@{isRefreshing}",
  "onPull": [
    {
      "_beagleAction_": "beagle:setContext",
      "contextId": "isRefreshing",
      "value": true
    }
  ],
  "children": [
    {
      "_beagleComponent_": "beagle:gridview",
      "id": "listView",
      "direction": "VERTICAL",
      "spanCount": 3,
      "dataSource": [0, 1, 2, 3, 4, 5, 6, 7, 8, 9],
      "templates": [
        {
          "view": {
            "_beagleComponent_": "beagle:text",
            "text": "@{item}"
          }
        }
      ]
    }
  ]
});

final button = BeagleUIElement({
  "_beagleComponent_": "beagle:container",
  "children": [
    {
      "_beagleComponent_": "beagle:button",
      "text": "Hello World",
      "onPress": [{
        "_beagleAction_": "beagle:alert",
        "message": "Clicked!"
      }],
      "style": {
        "backgroundColor": "green",
        "cornerRadius": {
          "radius": 50
        },
        "borderWidth": 5,
        "size": {
          "height": {
            "value": 100,
            "type": "REAL"
          },
          "width": {
            "value": 100,
            "type": "REAL"
          }
        },
        "margin": {
          "all": {
            "value": 10,
            "type": "REAL"
          }
        }
      }
    },
    {
      "_beagleComponent_": "beagle:button",
      "text": "Hello World",
      "onPress": [{
        "_beagleAction_": "beagle:alert",
        "message": "Clicked!"
      }],
      "style": {
        "cornerRadius": {
          "radius": 0
        },
        "borderColor": "pink",
        "size": {
          "width": {
            "value": 200,
            "type": "REAL"
          }
        },
        "margin": {
          "all": {
            "value": 10,
            "type": "REAL"
          }
        }
      }
    },
    {
      "_beagleComponent_": "beagle:button",
      "text": "Hello World",
      "onPress": [{
        "_beagleAction_": "beagle:alert",
        "message": "Clicked!"
      }],
      "style": {
        "borderColor": "pink",
        "borderWidth": 6,
        "size": {
          "height": {
            "value": 100,
            "type": "REAL"
          }
        },
        "margin": {
          "all": {
            "value": 10,
            "type": "REAL"
          }
        }
      }
    },
    {
      "_beagleComponent_": "beagle:button",
      "text": "Hello World",
      "onPress": [{
        "_beagleAction_": "beagle:alert",
        "message": "Clicked!"
      }],
      "style": {
        "size": {
          "width": {
            "value": 80,
            "type": "PERCENT"
          }
        },
        "margin": {
          "all": {
            "value": 10,
            "type": "REAL"
          }
        }
      }
    },
    {
      "_beagleComponent_": "beagle:button",
      "text": "Hello World",
      "onPress": [{
        "_beagleAction_": "beagle:alert",
        "message": "Clicked!"
      }],
      "style": {
        "margin": {
          "all": {
            "value": 10,
            "type": "REAL"
          }
        },
        "padding": {
          "left": {
            "value": 50,
            "type": "REAL"
          },
          "bottom": {
            "value": 20,
            "type": "REAL"
          }
        }
      }
    },
    {
      "_beagleComponent_": "beagle:button",
      "text": "Hello World",
      "onPress": [{
        "_beagleAction_": "beagle:alert",
        "message": "Clicked!"
      }],
      "style": {
        "margin": {
          "all": {
            "value": 10,
            "type": "REAL"
          }
        }
      }
    },
  ]
});

final textInput = BeagleUIElement({
  "_beagleComponent_": "beagle:textInput",
  "placeholder": "Hello World!",
  "style": {
    "margin": {
      "all": {
        "value": 30,
        "type": "REAL"
      }
    },
    "padding": {
      "horizontal": {
        "value": 50,
        "type": "REAL"
      },
      "vertical": {
        "value": 80,
        "type": "REAL"
      }
    },
    "size": {
      "height": {
        "value": 100,
        "type": "REAL"
      },
      "width": {
        "value": 100,
        "type": "REAL"
      }
    },
    "backgroundColor": "#AAFFAA",
    "cornerRadius": {
      "bottomLeft": 50
    },
    "borderWidth": 5,
    "borderColor": "#00AA00"
  }
});

final sendRequest = BeagleUIElement({
  "_beagleComponent_": "beagle:container",
  "style": {
    "flex": {
      "flex": 1,
      "alignItems": "CENTER",
      "justifyContent": "CENTER"
    }
  },
  "children":[
    {
      "_beagleComponent_": "beagle:button",
      "text": "Send",
      "onPress": [{
        "_beagleAction_": "beagle:sendRequest",
        "url": "https://gist.githubusercontent.com/Tiagoperes/1779f11f2298b552e723767e88ed3bc9/raw/4eb3d974e9c87692be258f815720e98fce4fe778/simple_json_text.json",
        "onSuccess": [{
          "_beagleAction_": "beagle:alert",
          "message": "@{onSuccess.data.message}"
        }],
        "onError": [{
          "_beagleAction_": "beagle:alert",
          "message": "> Error <"
        }]
      }]
    }
  ]
});
