import { MyCollectionArtworkAboutTestsQuery } from "__generated__/MyCollectionArtworkAboutTestsQuery.graphql"
import { renderWithWrappersTL } from "app/tests/renderWithWrappers"
import React from "react"
import { graphql, QueryRenderer } from "react-relay"
import { createMockEnvironment, MockPayloadGenerator } from "relay-test-utils"
import { MyCollectionArtworkAbout } from "./MyCollectionArtworkAbout"

jest.unmock("react-relay")

describe("MyCollectionArtworkAbout", () => {
  let mockEnvironment: ReturnType<typeof createMockEnvironment>
  const TestRenderer = () => (
    <QueryRenderer<MyCollectionArtworkAboutTestsQuery>
      environment={mockEnvironment}
      query={graphql`
        query MyCollectionArtworkAboutTestsQuery @relay_test_operation {
          artwork(id: "blue-chip-artwork") {
            ...MyCollectionArtworkAbout_artwork
          }
          marketPriceInsights(artistId: "artesian", medium: "Painting") {
            ...MyCollectionArtworkAbout_marketPriceInsights
          }
        }
      `}
      variables={{}}
      render={({ props }) => {
        if (props?.artwork && props?.marketPriceInsights) {
          return (
            <MyCollectionArtworkAbout
              marketPriceInsights={props.marketPriceInsights}
              artwork={props?.artwork}
            />
          )
        }
        return null
      }}
    />
  )

  beforeEach(() => {
    mockEnvironment = createMockEnvironment()
  })

  const resolveData = (resolvers = {}) => {
    mockEnvironment.mock.resolveMostRecentOperation((operation) =>
      MockPayloadGenerator.generate(operation, resolvers)
    )
  }

  it("renders about the work section", () => {
    const { getByText } = renderWithWrappersTL(<TestRenderer />)

    resolveData({
      Query: () => ({
        artwork: {
          category: "Oil on Canvas",
          medium: "Painting",
          date: "2007",
          provenance: "Signed, Sealed, Delivered!",
          dimensions: {
            in: "39 2/5 × 40 9/10 in",
            cm: "100 × 104 cm",
          },
        },
        marketPriceInsights: {
          lowRangeCents: 1780000,
          highRangeCents: 4200000,
        },
      }),
    })

    expect(getByText("Estimate Range")).toBeTruthy()
    expect(getByText("$17,800 - $42,000")).toBeTruthy()
    expect(getByText("Medium")).toBeTruthy()
    expect(getByText("Oil on canvas")).toBeTruthy()
    expect(getByText("Materials")).toBeTruthy()
    expect(getByText("Painting")).toBeTruthy()
    expect(getByText("Dimensions")).toBeTruthy()
    expect(getByText("39 2/5 × 40 9/10 in 100 × 104 cm")).toBeTruthy()
    expect(getByText("Year created")).toBeTruthy()
    expect(getByText("2007")).toBeTruthy()
    expect(getByText("Provenance")).toBeTruthy()
    expect(getByText("Signed, Sealed, Delivered!")).toBeTruthy()
  })

  it("renders purchase details section", () => {
    const { getByText } = renderWithWrappersTL(<TestRenderer />)

    resolveData({
      Query: () => ({
        artwork: {
          pricePaid: { display: "€224,000" },
        },
        marketPriceInsights: {},
      }),
    })

    expect(getByText("Purchase Details")).toBeTruthy()

    expect(getByText("Price Paid")).toBeTruthy()
    expect(getByText("€224,000")).toBeTruthy()
  })

  it("renders articles section", () => {
    const { getByText, getByTestId } = renderWithWrappersTL(<TestRenderer />)

    resolveData({
      Query: () => ({
        artwork: {
          artistNames: "Banksy",
          articles: {
            edges: [
              {
                node: {
                  id: "id1",
                  internalID: "internalId1",
                  slug: "article1",
                  author: { name: "Artsy" },
                  href: "/article/id1",
                  thumbnailImage: { url: "https://article1/image" },
                  thumbnailTitle: "article 1",
                  vertical: "Art Market",
                },
              },
            ],
          },
        },
        marketPriceInsights: {},
      }),
    })

    expect(getByText("Articles featuring Banksy")).toBeTruthy()
    expect(getByTestId("test-articles-flatlist")).toBeTruthy()
  })
})
