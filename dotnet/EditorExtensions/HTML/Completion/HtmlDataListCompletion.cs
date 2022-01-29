﻿using System;
using System.Collections.Generic;
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
    [HtmlCompletionProvider(CompletionTypes.Values, "input", "list")]
    [ContentType(HtmlContentTypeDefinition.HtmlContentType)]
    public class HtmlDataListCompletion : IHtmlCompletionListProvider, IHtmlTreeVisitor
    {
        public string CompletionType
        {
            get { return CompletionTypes.Values; }
        }

        public IList<HtmlCompletion> GetEntries(HtmlCompletionContext context)
        {
            var list = new HashSet<string>();

            context.Document.HtmlEditorTree.RootNode.Accept(this, list);

            return list.Select(s => new SimpleHtmlCompletion(s, context.Session)).ToList<HtmlCompletion>();
        }

        public bool Visit(ElementNode element, object parameter)
        {
            if (element.Name.Equals("datalist", StringComparison.OrdinalIgnoreCase))
            {
                var list = (HashSet<string>)parameter;
                list.Add(element.Id);
            }

            return true;
        }
    }
}
