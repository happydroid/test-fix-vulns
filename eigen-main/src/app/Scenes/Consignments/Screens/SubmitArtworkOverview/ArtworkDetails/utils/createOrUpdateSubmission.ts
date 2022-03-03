import {
  ConsignmentAttributionClass,
  CreateSubmissionMutationInput,
} from "__generated__/createConsignmentSubmissionMutation.graphql"
import { UpdateSubmissionMutationInput } from "__generated__/updateConsignSubmissionMutation.graphql"
import { createConsignSubmission, updateConsignSubmission } from "../../Mutations"
import { ArtworkDetailsFormModel } from "../validation"
import { limitedEditionValue } from "./rarityOptions"

export type SubmissionInput = CreateSubmissionMutationInput | UpdateSubmissionMutationInput

export const createOrUpdateSubmission = async (
  values: ArtworkDetailsFormModel,
  submissionId: string
) => {
  const isRarityLimitedEdition = values.attributionClass === limitedEditionValue
  const attributionClass =
    (values?.attributionClass?.replace(" ", "_").toUpperCase() as ConsignmentAttributionClass) ||
    null

  const submissionValues: SubmissionInput = {
    artistID: values.artistId,
    year: values.year,
    title: values.title,
    medium: values.medium,
    attributionClass,
    editionNumber: isRarityLimitedEdition ? values.editionNumber : "",
    editionSizeFormatted: isRarityLimitedEdition ? values.editionSizeFormatted : "",
    height: values.height,
    width: values.width,
    depth: values.depth,
    dimensionsMetric: values.dimensionsMetric,
    provenance: values.provenance,
    locationCity: values.location.city,
    locationState: values.location.state,
    locationCountry: values.location.country,
    state: "DRAFT",
    utmMedium: values.utmMedium,
    utmSource: values.utmSource,
    utmTerm: values.utmTerm,
  }

  if (submissionId) {
    return await updateConsignSubmission({
      id: submissionId,
      ...submissionValues,
    } as UpdateSubmissionMutationInput)
  }

  return await createConsignSubmission(submissionValues as CreateSubmissionMutationInput)
}
