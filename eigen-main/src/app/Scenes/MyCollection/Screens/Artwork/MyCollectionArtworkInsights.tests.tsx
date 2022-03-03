import { MyCollectionArtworkInsightsTestsQuery } from "__generated__/MyCollectionArtworkInsightsTestsQuery.graphql"
import { renderWithWrappersTL } from "app/tests/renderWithWrappers"
import React from "react"
import { graphql, QueryRenderer } from "react-relay"
import { createMockEnvironment, MockPayloadGenerator } from "relay-test-utils"
import { MyCollectionArtworkInsights } from "./MyCollectionArtworkInsights"

jest.unmock("react-relay")

describe("MyCollectionArtworkInsights", () => {
  let mockEnvironment: ReturnType<typeof createMockEnvironment>
  const TestRenderer = () => (
    <QueryRenderer<MyCollectionArtworkInsightsTestsQuery>
      environment={mockEnvironment}
      query={graphql`
        query MyCollectionArtworkInsightsTestsQuery @relay_test_operation {
          artwork(id: "some-artwork-id") {
            ...MyCollectionArtworkInsights_artwork
          }

          marketPriceInsights(artistId: "some-artist-id", medium: "painting") {
            ...MyCollectionArtworkInsights_marketPriceInsights
          }
        }
      `}
      variables={{}}
      render={({ props }) => {
        if (props?.artwork && props?.marketPriceInsights) {
          return (
            <MyCollectionArtworkInsights
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

  it("renders without throwing an error", () => {
    const { getByText } = renderWithWrappersTL(<TestRenderer />)
    resolveData({
      Query: () => ({
        artwork: mockArtwork,
        marketPriceInsights: mockMarketPriceInsights,
      }),
    })

    expect(getByText("Price & Market Insights")).toBeTruthy()

    // Demand Index

    expect(getByText("Strong Demand (7.0 – 9.0)")).toBeTruthy()
    expect(
      getByText(
        "Demand is higher than the supply available in the market and sale price exceeds estimates."
      )
    ).toBeTruthy()

    // Artwork Artist Market

    expect(getByText("Artist Market")).toBeTruthy()
    expect(getByText("Based on the last 36 months of auction data")).toBeTruthy()
    expect(getByText("Annual Value Sold")).toBeTruthy()
    expect(getByText("$1,000")).toBeTruthy()
    expect(getByText("Annual Lots Sold")).toBeTruthy()
    expect(getByText("100")).toBeTruthy()
    expect(getByText("Sell-through Rate")).toBeTruthy()
    expect(getByText("20%")).toBeTruthy()
    expect(getByText("Sale Price to Estimate")).toBeTruthy()
    expect(getByText("1x")).toBeTruthy()
    expect(getByText("Liquidity")).toBeTruthy()
    expect(getByText("High")).toBeTruthy()
    expect(getByText("One-Year Trend")).toBeTruthy()
    expect(getByText("Trending up")).toBeTruthy()

    // Why Sell

    expect(getByText("Interested in selling this work?")).toBeTruthy()
  })
})

const mockArtwork = {}

const mockMarketPriceInsights = {
  demandRank: 0.7,
  demandTrend: 9,
  sellThroughRate: 20,
  annualLotsSold: 100,
  annualValueSoldCents: 100000,
  medianSaleToEstimateRatio: 1,
  liquidityRank: 0.7,
}
