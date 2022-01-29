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
    [HtmlCompletionProvider(CompletionTypes.Values, "label", "for")]
    [ContentType(HtmlContentTypeDefinition.HtmlContentType)]
    public class HtmlLabelForAttributeCompletion : IHtmlCompletionListProvider, IHtmlTreeVisitor
    {
        private static readonly List<string> _inputTypes = new List<string>() { "input", "textarea", "select" };
        public string CompletionType
        {
            get { return CompletionTypes.Values; }
        }

        public IList<HtmlCompletion> GetEntries(HtmlCompletionContext context)
        {
            var list = new HashSet<string>();

            context.Document.HtmlEditorTree.RootNode.Accept(this, list);

            return new List<HtmlCompletion>(list.Select(s => new SimpleHtmlCompletion(s, context.Session)));
        }

        public bool Visit(ElementNode element, object parameter)
        {
            if (_inputTypes.Contains(element.Name.ToLowerInvariant()))
            {
                var list = (HashSet<string>)parameter;
                var id = element.GetAttribute("id");

                if (id != null)
                    list.Add(id.Value);
            }

            return true;
        }
    }
}
