﻿using System.Collections.Generic;
using System.Linq;
using Microsoft.Html.Core;
using Microsoft.VisualStudio.Utilities;
using Microsoft.Web.Editor;
using Microsoft.Html.Editor.Completion.Def;
using Microsoft.Web.Core.ContentTypes;
using Microsoft.Html.Core.Tree.Nodes;
using Microsoft.Html.Editor.Completion;

namespace MadsKristensen.EditorExtensions.Html
{
    [HtmlCompletionProvider(CompletionTypes.Values, "*", "id")]
    [ContentType(HtmlContentTypeDefinition.HtmlContentType)]
    public class InputIdAttributeCompletion : IHtmlCompletionListProvider, IHtmlTreeVisitor
    {
        private static readonly HashSet<string> _inputTypes = new HashSet<string>() { "input", "textarea", "select" };

        public string CompletionType
        {
            get { return CompletionTypes.Values; }
        }

        public IList<HtmlCompletion> GetEntries(HtmlCompletionContext context)
        {
            var list = new HashSet<string>();

            if (context.Element != null && _inputTypes.Contains(context.Element.Name))
            {
                context.Document.HtmlEditorTree.RootNode.Accept(this, list);
            }

            return new List<HtmlCompletion>(list.Select(s => new SimpleHtmlCompletion(s, context.Session)));
        }

        public bool Visit(ElementNode element, object parameter)
        {
            if (element.Name == "label")
            {
                var list = (HashSet<string>)parameter;
                var forAttr = element.GetAttribute("for");

                if (forAttr != null)
                    list.Add(forAttr.Value);
            }

            return true;
        }
    }
}
