﻿using System;
using System.Collections.Generic;
using Microsoft.VisualStudio.Utilities;
using Microsoft.Web.Editor;
using Microsoft.Html.Editor.Completion.Def;
using Microsoft.Web.Core.ContentTypes;

namespace MadsKristensen.EditorExtensions.Html
{
    [HtmlCompletionProvider(CompletionTypes.Values, "meta", "content")]
    [ContentType(HtmlContentTypeDefinition.HtmlContentType)]
    public class TwitterCardCompletion : StaticListCompletion
    {
        protected override string KeyProperty { get { return "name"; } }
        public TwitterCardCompletion()
            : base(new Dictionary<string, IEnumerable<string>>(StringComparer.OrdinalIgnoreCase)
            {
                { "twitter:card",  Values("app", "gallery", "photo", "player", "product", "summary", "summary_large_image") }
            }) { }
    }
}
