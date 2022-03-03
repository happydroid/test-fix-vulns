import { ConsignmentSetup } from "app/Scenes/Consignments"
import ConsignmentTODO from "app/Scenes/Consignments/Components/ArtworkConsignmentTodo"

it("requires the same metadata props as force", () => {
  const requiredProps: ConsignmentSetup = {
    metadata: {
      category: "ARCHITECTURE",
      categoryName: "Architecture",
      title: "Work",
      year: "123",
      medium: "123",
      width: "123",
      height: "12",
      depth: 12,
      unit: "CM",
      displayString: "A work",
    },
  }
  const todo = new ConsignmentTODO(requiredProps)
  expect(todo.canSubmitMetadata(requiredProps)).toBeTruthy()
})
it("fails if the right metadata props aren't present", () => {
  const requiredProps: any = {
    metadata: {
      category: "a",
      categoryName: "A",
      title: "Work",
      year: "123",
      width: "123",
      height: "12",
      depth: 12,
      unit: "CM",
      displayString: "A work",
    },
  }
  const todo = new ConsignmentTODO(requiredProps)
  expect(todo.canSubmitMetadata(requiredProps)).toBeFalsy()
})
