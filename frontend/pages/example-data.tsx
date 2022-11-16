import { nodesFromEdges } from '@shopify/admin-graphql-api-utilities'
import {
  Card, Layout, List, Page, SkeletonBodyText, SkeletonPage, TextStyle,
} from '@shopify/polaris'
import { gql } from 'graphql-request'
import { ProductConnection } from 'types/shopify'
import { useAppQuery } from '../hooks/useAppQuery'
import { useShopifyQuery } from '../hooks/useShopifyQuery'

const PRODUCTS_QUERY = gql`
  {
    products(first: 10, reverse: true) {
      edges {
        node {
          id
          title
          handle
        }
      }
    }
  }
`

interface ProductsData {
  products: ProductConnection
}

export default function ExampleDataPage () {
  const {
    data,
    isLoading,
  } = useAppQuery({
    url: `/api/shops/me`,
  });

  const products = useShopifyQuery<ProductsData>('products',{
    query: PRODUCTS_QUERY,
  })
  console.log({ products })

  function renderLoading () {
    return (
      <SkeletonPage title="Example Shop data">
        <Layout>
          <Layout.Section>
            <Card title="Local shop data" sectioned>
              <SkeletonBodyText />
            </Card>
          </Layout.Section>

          <Layout.Section>
            <Card title="Remote product data" sectioned>
              <SkeletonBodyText />
            </Card>
          </Layout.Section>
        </Layout>
      </SkeletonPage>
    )
  }

  if (isLoading) {
    return renderLoading()
  }

  function renderProducts () {
    if ((products?.data?.data?.products?.edges?.length ?? 0) === 0) {
      return <p>This store has no products!</p>
    }

    return (
      <List>
        {nodesFromEdges(products.data.data.products.edges).map(node => (
          <List.Item>
            <TextStyle variation="strong">{node.title}</TextStyle> ({node.handle})<br />
            <TextStyle variation="code">{node.id}</TextStyle>
          </List.Item>
        ))}
      </List>
    )
  }

  return (
    <Page title="Example Shop data">
      <Layout>
        <Layout.Section>
          <Card title="Local shop data" sectioned>
            <p>Shop: {data?.shopifyDomain}</p>
          </Card>
        </Layout.Section>

        <Layout.Section>
          <Card title="Remote product data" sectioned>
            {renderProducts()}
          </Card>
        </Layout.Section>
      </Layout>
    </Page>
  )
}
