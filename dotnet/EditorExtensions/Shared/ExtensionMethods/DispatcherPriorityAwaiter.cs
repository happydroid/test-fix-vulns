using System;
using System.Runtime.CompilerServices;
using System.Windows.Threading;

namespace MadsKristensen.EditorExtensions
{
    /// <summary>
    ///     A simple awaiter type that will queue the continuation to a
    ///     dispatcher at a specific priority.
    /// </summary>
    /// <remarks>
    ///     This is returned from DispatcherPriorityAwaitable.GetAwaiter()
    /// </remarks>
    public struct DispatcherPriorityAwaiter : INotifyCompletion
    {
        /// <summary>
        ///     Creates an instance of DispatcherPriorityAwaiter that will
        ///     queue any continuations to the specified Dispatcher at the
        ///     specified priority.
        /// </summary>
        public DispatcherPriorityAwaiter(Dispatcher dispatcher, DispatcherPriority priority)
        {
            _dispatcher = dispatcher;
            _priority = priority;
        }

        /// <summary>
        ///     This awaiter is just a proxy for queuing the continuations, it
        ///     never completes itself.
        /// </summary>
        public bool IsCompleted { get { return false; } }

        /// <summary>
        ///     This awaiter is just a proxy for queuing the continuations, it
        ///     never completes itself, so it doesn't have any result.
        /// </summary>
        public void GetResult() { }

        /// <summary>
        ///     This is called with the continuation, which is simply queued to
        ///     the Dispatcher at the priority specified to the constructor.
        /// </summary>
        public void OnCompleted(Action continuation)
        {
            if (_dispatcher == null)
            {
                throw new InvalidOperationException("Cannot await an empty DispatcherPriorityAwaiter");
            }

            _dispatcher.InvokeAsync(continuation, _priority);
        }

        private readonly Dispatcher _dispatcher;
        private readonly DispatcherPriority _priority;
    }
}

