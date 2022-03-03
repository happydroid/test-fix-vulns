import { __globalStoreTestUtils__ } from "app/store/GlobalStore"
import { renderWithWrappersTL } from "app/tests/renderWithWrappers"
import { useFormikContext } from "formik"
import React from "react"
import { ArtworkDetailsForm } from "./ArtworkDetailsForm"
import { mockFormValues } from "./utils/testUtils"

jest.mock("formik")

const useFormikContextMock = useFormikContext as jest.Mock

describe("ArtworkDetailsForm", () => {
  beforeEach(() => {
    useFormikContextMock.mockImplementation(() => ({
      handleSubmit: jest.fn(),
      handleChange: jest.fn(),
      setFieldValue: jest.fn(),
      errors: {},
      values: mockFormValues,
    }))
  })

  it("correctly displays formik values in form", () => {
    const { findByText } = renderWithWrappersTL(<ArtworkDetailsForm />)
    expect(findByText("hello")).toBeTruthy()
    expect(findByText("Caspar David Friedrich")).toBeTruthy()
    expect(findByText("oil on canvas")).toBeTruthy()
    expect(findByText("found")).toBeTruthy()
    expect(findByText("London")).toBeTruthy()
  })

  it("when rarity is limited edition, renders additional inputs for edition number and size", () => {
    const { getByTestId } = renderWithWrappersTL(<ArtworkDetailsForm />)

    const inputs = {
      editionNumber: getByTestId("Submission_EditionNumberInput"),
      editionSize: getByTestId("Submission_EditionSizeInput"),
    }

    expect(inputs.editionNumber).toBeTruthy()
    expect(inputs.editionSize).toBeTruthy()
  })
})
