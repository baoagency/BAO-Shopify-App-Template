/**
 * How to use:
 *   1. "npm i -D graphql-schema-typescript"
 *   2. Update URL in .graphqlconfig to match the store you're developing on
 *   3. Grab the Access Token from the store you've installed this app against in your database
 *   4. (Only know of how to do this in Webstorm currently) Run the introspection query to generate the ./schema.graphql
 *   5. Run this file "node generate-shopify-graphql-types.js"
*/

const fs = require('fs')
const { generateTypeScriptTypes } = require('graphql-schema-typescript')

const schema = fs.readFileSync('./schema.graphql').toString()

generateTypeScriptTypes(schema, './frontend/types/shopify.d.ts', { typePrefix: "" })
  .then(() => {
    console.log('DONE');
    process.exit(0);
  })
  .catch(err =>{
    console.error(err);
    process.exit(1);
  });
