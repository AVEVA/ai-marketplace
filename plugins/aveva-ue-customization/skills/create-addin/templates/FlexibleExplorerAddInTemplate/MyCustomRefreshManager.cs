//Copyright 1974 to current year. AVEVA Solutions Limited and its subsidiaries. All rights reserved in original code only.
using Aveva.Core.FlexibleExplorer;
namespace Aveva.Core.Samples
{
    /// <summary>
    /// Custom Refresh Manager.
    /// </summary>
    public class MyCustomRefreshManager : IFlexibleExplorerRefreshManager
    {
        /// <summary>
        /// GetRefreshType
        /// </summary>
        /// <param name="refreshArguments"></param>
        /// <returns></returns>
        public RefreshArguments GetRefreshType(RefreshArguments refreshArguments)
        {
            if (refreshArguments.DbChangesEventArgs == null && refreshArguments.DbRawChanges == null)
            {
                refreshArguments.RefreshType = RefreshOperation.None;
                return refreshArguments;
            }

            //Add code here to cover all other situations for your Flexible Explorer Definition. ie set the RefreshType
            //refreshArguments.RefreshType = RefreshOperation.None;
            //refreshArguments.RefreshType = RefreshOperation.NodesOnly;
            //refreshArguments.RefreshType = RefreshOperation.NodesWithCollections;
            //refreshArguments.RefreshType = RefreshOperation.WholeTree;

            //Return the input argument as a default.
            return refreshArguments;
        }
    }
}
