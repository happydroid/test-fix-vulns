using Microsoft.AspNetCore.Mvc;
using NzbDrone.Core.Profiles;
using Radarr.Http;

namespace Radarr.Api.V3.Profiles.Quality
{
    [V3ApiController("qualityprofile/schema")]
    public class QualityProfileSchemaController : Controller
    {
        private readonly IProfileService _profileService;

        public QualityProfileSchemaController(IProfileService profileService)
        {
            _profileService = profileService;
        }

        [HttpGet]
        public QualityProfileResource GetSchema()
        {
            var qualityProfile = _profileService.GetDefaultProfile(string.Empty);

            return qualityProfile.ToResource();
        }
    }
}
