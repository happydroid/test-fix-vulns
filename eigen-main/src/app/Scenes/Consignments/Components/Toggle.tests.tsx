import { renderWithWrappers } from "app/tests/renderWithWrappers"
import React from "react"
import Toggle from "./Toggle"

it("renders without throwing an error", () => {
  renderWithWrappers(<Toggle selected left="L" right="R" />)
})
