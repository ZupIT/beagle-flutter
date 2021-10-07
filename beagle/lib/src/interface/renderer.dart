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
import 'package:flutter/widgets.dart';

abstract class Renderer {
  /// Does a partial render to the BeagleView. Compared to the full render, it will skip every step
  /// until the view snapshot, i.e, it will start by taking the view snapshot and end doing a render
  /// to the screen. Useful when updating components that have already been rendered once. If any
  /// component in [tree] haven't been rendered before, you should use `doFullRender` instead.
  ///
  /// To see the full documentation of the renderization process, please follow this link:
  /// https://github.com/ZupIT/beagle-web-core/blob/main/docs/renderization.md
  ///
  /// The parameter [tree] is the new tree to render, it can be just a new branch to add to the
  /// current tree or the entire tree. If it's the entire tree, the second and third parameter can
  /// be ommited.
  /// If you wish to update a branch of the tree, you must specify the second parameter [anchor]
  /// which is the id of the element in the current tree to add the new branch ([tree]) to.
  /// The third parameter [mode] tells Beagle how to add this tree to [anchor]. Prepend adds the new
  /// element to the start of the list of children. Append ads the children at the end. Replace
  /// remove all current children and adds [tree] as the only child. ReplaceComponent will replace
  /// the element identified by [anchor] entirely by [tree]. Default is replaceComponent.
  void doPartialRender(BeagleUIElement tree,
      [String anchor, TreeUpdateMode mode]);

  /// Does a full render to the BeagleView. A full render means that every renderization step will
  /// be executed for the [tree] passed as parameter. If the components in [tree] have been rendered
  /// at least once, you can help performance by calling `doPartialRender` instead.
  ///
  /// To see the full documentation of the renderization process, please follow this link:
  /// https://github.com/ZupIT/beagle-web-core/blob/main/docs/renderization.md
  ///
  /// The parameter [tree] is the new tree to render, it can be just a new branch to add to the
  /// current tree or the entire tree. If it's the entire tree, the second and third parameter can
  /// be ommited.
  /// If you wish to update a branch of the tree, you must specify the second parameter [anchor]
  /// which is the id of the element in the current tree to add the new branch ([tree]) to.
  /// The third parameter [mode] tells Beagle how to add this tree to [anchor]. Prepend adds the new
  /// element to the start of the list of children. Append ads the children at the end. Replace
  /// remove all current children and adds [tree] as the only child. ReplaceComponent will replace
  /// the element identified by [anchor] entirely by [tree]. Default is replaceComponent.
  void doFullRender(BeagleUIElement tree, [String anchor, TreeUpdateMode mode]);

  /// Renders according to a template manager and a matrix of contexts.
  ///
  /// Each line in the matrix of contexts represents an iteration and each column represents the value
  /// of a template variable. For instance, imagine a template with the variables `@{name}`, `@{sex}`
  /// and `@{address}`. Now suppose we want to render three different entries with this template.
  /// Here's a context matrix that could be used for this example:
  ///
  /// [
  ///   [{ id: 'name', value: 'John' }, { id: 'sex', value: 'M' }, { id: 'address', value: { street: '42 Avenue', number: '256' } }],
  ///   [{ id: 'name', value: 'Sue' }, { id: 'sex', value: 'F' }, { id: 'address', value: { street: 'St Monica St', number: '85' } }],
  ///   [{ id: 'name', value: 'Paul' }, { id: 'sex', value: 'M' }, { id: 'address', value: { street: 'Bv Kennedy', number: '877' } }],
  /// ]
  ///
  /// Note that the parameter `contexts` adds to the context hierarchy that is already present in the
  /// tree, it doesn't replace it, i.e. you can still use the contexts declared in the current tree.
  ///
  /// For each line of the context matrix, a template is chosen from the template manager according to
  /// `case`, which is a boolean or a beagle expression that resolves to a boolean. When `case` is an
  /// expression, it's resolved using the entire context of the current tree plus the contexts passed
  /// in the parameter `contexts` corresponding to the current iteration. If no template attends the
  /// condition the default template is used. If there's no default template, the iteration is skipped.
  ///
  /// After processing all items, the resulting tree is attached to the current tree at the node with
  /// id `anchor` (passed as parameter).
  ///
  /// The component manager is an optional parameter and is used to modify the resulting component.
  /// This can be very useful for managing ids, for instance. The component manager is a function that
  /// receives the component generated and the index of the current iteration, returning the modified
  /// component.
  ///
  /// @param templateManager templates used to render each line of the context matrix.
  /// @param anchor the id of the node in the current tree to attach the new nodes to.
  /// @param contexts matrix of contexts where each line represents an item to be rendered according to
  /// the templateManager.
  /// @param componentManager optional. When set, the component goes through this function before being
  /// finally rendered.
  /// @param mode optional. when `viewTree` is just a new branch to be added to the tree, the mode must be
  /// specified. It can be `append`, `prepend` or `replace`. The default value is `replace`
  void doTemplateRender({
    required TemplateManager templateManager,
    required String anchor,
    required List<List<BeagleDataContext>> contexts,
    BeagleUIElement Function(BeagleUIElement, int)? componentManager,
    TreeUpdateMode? mode,
  });
}
