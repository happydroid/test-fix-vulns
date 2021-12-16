﻿using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace NzbDrone.Common.Http
{
    public static class UserAgentParser
    {
        public static string SimplifyUserAgent(string userAgent)
        {
            if (userAgent == null || userAgent.StartsWith("Mozilla/5.0"))
            {
                return null;
            }

            return userAgent;
        }
    }
}
