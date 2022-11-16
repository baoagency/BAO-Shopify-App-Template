import { Card, Page, Layout, TextContainer, Heading } from "@shopify/polaris";

export default function ExamplePage() {
  return (
    <Page title="Example page">
      <Layout>
        <Layout.Section>
          <Card sectioned>
            <Heading>Heading</Heading>
            <TextContainer>
              <p>Body</p>
            </TextContainer>
          </Card>

          <Card sectioned>
            <Heading>Heading</Heading>
            <TextContainer>
              <p>Body</p>
            </TextContainer>
          </Card>
        </Layout.Section>

        <Layout.Section secondary>
          <Card sectioned>
            <Heading>Heading</Heading>

            <TextContainer>
              <p>Body</p>
            </TextContainer>
          </Card>
        </Layout.Section>
      </Layout>
    </Page>
  );
}
