import { useAppBridge } from '@shopify/app-bridge-react'

export function useShopifyDomain () {
  const app = useAppBridge()
  const shopifyDomainURL = new URL(app.hostOrigin)

  return shopifyDomainURL.host.replace('.myshopify.com', '')
}
