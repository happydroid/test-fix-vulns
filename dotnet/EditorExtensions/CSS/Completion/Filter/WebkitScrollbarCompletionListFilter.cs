﻿using System.Collections.Generic;
using System.Collections.Specialized;
using System.ComponentModel.Composition;
using Microsoft.CSS.Core;
using Microsoft.VisualStudio.Utilities;
using Microsoft.CSS.Editor.Completion;
using Microsoft.CSS.Core.Parser;
using Microsoft.Web.Editor.Completion;

namespace MadsKristensen.EditorExtensions.Css
{
	[Export(typeof(ICssCompletionListFilter))]
	[Name("WebkitScrollbarCompletionListFilter")]
	internal class WebkitScrollbarCompletionListFilter : ICssCompletionListFilter
	{
		private static readonly StringCollection _cache = new StringCollection()
		{
			":horizontal",
			":vertical",
			":decrement",
			":increment",
			":start",
			":end",
			":double-button",
			":single-button",
			":no-button",
			":corner-present",
			":window-inactive",
		};

		public void FilterCompletionList(IList<CssCompletionEntry> completions, CssCompletionContext context)
		{
			if (context.ContextType != CssCompletionContextType.PseudoClassOrElement)
				return;

			ParseItem prev = context.ContextItem.PreviousSibling;
			bool hasScrollbar = false;

			if (prev != null)
			{
				hasScrollbar = prev.Text.Contains(":-webkit-resizer") || prev.Text.Contains(":-webkit-scrollbar");
			}

			foreach (CssCompletionEntry entry in completions)
			{
				if (hasScrollbar)
				{
					entry.FilterType = _cache.Contains(entry.DisplayText) ? entry.FilterType : CompletionEntryFilterTypes.NeverVisible;
				}
				else
				{
					entry.FilterType = !_cache.Contains(entry.DisplayText) ? entry.FilterType : CompletionEntryFilterTypes.NeverVisible;
				}
			}
		}
	}
}