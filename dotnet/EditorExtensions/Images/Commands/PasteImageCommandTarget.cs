﻿using System;
using System.Drawing;
using System.Drawing.Imaging;
using System.Globalization;
using System.IO;
using System.Linq;
using System.Text.RegularExpressions;
using System.Windows.Forms;
using Microsoft.VisualStudio;
using Microsoft.VisualStudio.Text;
using Microsoft.VisualStudio.Text.Editor;
using Microsoft.VisualStudio.Text.Projection;
using Microsoft.VisualStudio.TextManager.Interop;
using Microsoft.Web.Core.ContentTypes;

namespace MadsKristensen.EditorExtensions.Images
{
    internal class PasteImage : CommandTargetBase<VSConstants.VSStd97CmdID>
    {
        private string _format;
        private static string _lastPath;

        public PasteImage(IVsTextView adapter, IWpfTextView textView)
            : base(adapter, textView, VSConstants.VSStd97CmdID.Paste)
        {
            WebEssentialsPackage.DTE.Events.SolutionEvents.AfterClosing += delegate { _lastPath = null; };
        }

        protected override bool Execute(VSConstants.VSStd97CmdID commandId, uint nCmdexecopt, IntPtr pvaIn, IntPtr pvaOut)
        {
            IDataObject data = Clipboard.GetDataObject();

            if (data == null) return false;

            var formats = data.GetFormats();

            if (formats == null) return false;

            // This is to check if the image is text copied from PowerPoint etc.
            bool trueBitmap = formats.Any(x => new[] { "DeviceIndependentBitmap", "PNG", "JPG", "System.Drawing.Bitmap" }.Contains(x));
            bool textFormat = formats.Any(x => new[] { "Text", "Rich Text Format" }.Contains(x));
            bool hasBitmap = data.GetDataPresent("System.Drawing.Bitmap") || data.GetDataPresent(DataFormats.FileDrop);

            if (!hasBitmap || !trueBitmap || textFormat || !IsValidTextBuffer())
                return false;

            string fileName = null;

            if (!GetFileName(data, out fileName))
                return true;

            _lastPath = Path.GetDirectoryName(fileName);

            SaveClipboardImageToFile(data, fileName);
            UpdateTextBuffer(fileName, WebEssentialsPackage.DTE.ActiveDocument.FullName);

            Telemetry.TrackEvent("Paste image");

            return true;
        }

        private bool IsValidTextBuffer()
        {
            var projection = TextView.TextBuffer as IProjectionBuffer;

            if (projection != null)
            {
                var snapshotPoint = TextView.Caret.Position.BufferPosition;

                var buffers = projection.SourceBuffers.Where(
                    s =>
                        s.ContentType.IsOfType("CSS")
                        || s.ContentType.IsOfType("JavaScript")
                        || s.ContentType.IsOfType("TypeScript")
                        || s.ContentType.IsOfType("CoffeeScript"));

                foreach (ITextBuffer buffer in buffers)
                {
                    SnapshotPoint? point = TextView.BufferGraph.MapDownToBuffer(snapshotPoint, PointTrackingMode.Negative, buffer, PositionAffinity.Predecessor);

                    if (point.HasValue)
                    {
                        _format = GetFormat(buffer);
                        return true;
                    }
                }

                _format = GetFormat(null);
                return true;
            }
            else
            {
                _format = GetFormat(TextView.TextBuffer);
                return true;
            }
        }

        private static string GetFormat(ITextBuffer buffer)
        {
            // CSS
            if (buffer != null)
            {
                if (buffer.ContentType.IsOfType(CssContentTypeDefinition.CssContentType))
                    return "background-image: url('{0}');";

                if (buffer.ContentType.IsOfType("JavaScript") || buffer.ContentType.IsOfType("TypeScript"))
                    return "var img = new Image();"
                         + Environment.NewLine
                         + "img.src = \"{0}\";";

                if (buffer.ContentType.IsOfType("CoffeeScript"))
                    return "img = new Image()"
                         + Environment.NewLine
                         + "img.src = \"{0}\"";
                            }

            return "<img src=\"{0}\" alt=\"{1}\" />";
        }

        private static bool GetFileName(IDataObject data, out string fileName)
        {
            string extension = "png";
            fileName = "file";

            if (data.GetDataPresent(DataFormats.FileDrop))
            {
                string fullpath = ((string[])data.GetData(DataFormats.FileDrop))[0];
                fileName = Path.GetFileName(fullpath);
                extension = Path.GetExtension(fileName).TrimStart('.');
            }
            else
            {
                extension = GetMimeType((Bitmap)data.GetData("System.Drawing.Bitmap"));
            }

            using (var dialog = new SaveFileDialog())
            {
                dialog.FileName = fileName;
                dialog.DefaultExt = "." + extension;
                dialog.Filter = extension.ToUpperInvariant() + " Files|*." + extension;
                dialog.InitialDirectory = _lastPath ?? Path.GetDirectoryName(WebEssentialsPackage.DTE.ActiveDocument.FullName);

                if (dialog.ShowDialog() != System.Windows.Forms.DialogResult.OK)
                    return false;

                fileName = dialog.FileName;
            }

            return true;
        }

        private static string GetMimeType(Bitmap bitmap)
        {
            if (bitmap.RawFormat.Guid == ImageFormat.Bmp.Guid)
                return "bmp";
            if (bitmap.RawFormat.Guid == ImageFormat.Emf.Guid)
                return "emf";
            if (bitmap.RawFormat.Guid == ImageFormat.Exif.Guid)
                return "exif";
            if (bitmap.RawFormat.Guid == ImageFormat.Gif.Guid)
                return "gif";
            if (bitmap.RawFormat.Guid == ImageFormat.Icon.Guid)
                return "icon";
            if (bitmap.RawFormat.Guid == ImageFormat.Jpeg.Guid)
                return "jpg";
            if (bitmap.RawFormat.Guid == ImageFormat.Tiff.Guid)
                return "tiff";
            if (bitmap.RawFormat.Guid == ImageFormat.Wmf.Guid)
                return "wmf";

            return "png";
        }

        private void UpdateTextBuffer(string fileName, string relativeTo)
        {
            int position = TextView.Caret.Position.BufferPosition.Position;
            string relative = MakeRelative(relativeTo, fileName);
            string altText = PrettifyAltText(fileName);
            string text = string.Format(CultureInfo.InvariantCulture, _format, relative, altText);

            using (WebEssentialsPackage.UndoContext("Insert Image"))
            {
                try
                {
                    TextView.TextBuffer.Insert(position, text);

                    SnapshotSpan span = new SnapshotSpan(TextView.TextBuffer.CurrentSnapshot, position, _format.Length);
                    TextView.Selection.Select(span, false);

                    WebEssentialsPackage.ExecuteCommand("Edit.FormatSelection");
                    TextView.Selection.Clear();
                }
                catch (Exception ex)
                {
                    Logger.Log(ex);
                }
            }
        }

        private static string PrettifyAltText(string fileName)
        {
            var text = Path.GetFileNameWithoutExtension(fileName)
                            .Replace("-", " ")
                            .Replace("_", " ");

            text = Regex.Replace(text, "(\\B[A-Z])", " $1");

            return CultureInfo.CurrentCulture.TextInfo.ToTitleCase(text);
        }

        public static string MakeRelative(string baseFile, string file)
        {
            Uri baseUri = new Uri(baseFile, UriKind.RelativeOrAbsolute);
            Uri fileUri = new Uri(file, UriKind.RelativeOrAbsolute);

            return Uri.UnescapeDataString(baseUri.MakeRelativeUri(fileUri).ToString());
        }

        public static async void SaveClipboardImageToFile(IDataObject data, string fileName)
        {
            if (data.GetDataPresent(DataFormats.FileDrop))
            {
                string original = ((string[])data.GetData(DataFormats.FileDrop))[0];

                if (File.Exists(original))
                    File.Copy(original, fileName, true);
            }
            else
            {
                using (Bitmap image = (Bitmap)data.GetData("System.Drawing.Bitmap"))
                using (MemoryStream ms = new MemoryStream())
                {
                    image.Save(ms, GetImageFormat(Path.GetExtension(fileName)));
                    byte[] buffer = ms.ToArray();
                    await FileHelpers.WriteAllBytesRetry(fileName, buffer);
                }
            }

            ProjectHelpers.AddFileToActiveProject(fileName);
        }

        public static ImageFormat GetImageFormat(string extension)
        {
            switch (extension.ToLowerInvariant())
            {
                case ".jpg":
                case ".jpeg":
                    return ImageFormat.Jpeg;

                case ".gif":
                    return ImageFormat.Gif;

                case ".bmp":
                    return ImageFormat.Bmp;

                case ".ico":
                    return ImageFormat.Icon;
            }

            return ImageFormat.Png;
        }

        protected override bool IsEnabled()
        {
            return true;
        }
    }
}