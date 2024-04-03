import {
  APIGatewayAuthorizerResult,
  APIGatewayTokenAuthorizerHandler,
} from "aws-lambda";
import jwt from "jsonwebtoken";
import { JwksClient } from "jwks-rsa";

type ProviderSettingType = {
  clientId: string | string[];
  jwksUri: string;
};

type Providers = {
  [iss: string]: ProviderSettingType;
};

const providers: Providers = {
  "https://accounts.google.com": {
    clientId: "YOUR_CLIENT",
    jwksUri: "https://www.googleapis.com/oauth2/v3/certs",
  },
  "https://login.github.com": {
    clientId: "YOUR_CLIENT",
    jwksUri: "https://tokens.github.com/.well-known/jwks.json",
  },
};

function getProvider(iss: string): ProviderSettingType {
  const provider = providers[iss];
  if (provider === undefined) {
    throw new Error("Invalid token: iss is not supported");
  }
  return provider;
}

function easyTokenValidator(
  token: string | jwt.JwtPayload | null,
): token is jwt.JwtPayload {
  return typeof token !== "string" && token !== null;
}

async function getPublicKey(provider: ProviderSettingType) {
  const client = new JwksClient({
    jwksUri: provider.jwksUri,
  });
  const keys = await client.getSigningKey();
  return keys.getPublicKey();
}

async function validateToken(token: string, provider: ProviderSettingType) {
  const key = await getPublicKey(provider);
  return jwt.verify(token, key, {
    audience: provider.clientId,
  });
}

function generatePolicy(
  principalId: string,
  effect: string,
  resource: string,
  uid: string | undefined,
): APIGatewayAuthorizerResult {
  const policyDocument = {
    Version: "2012-10-17",
    Statement: [
      {
        Action: "execute-api:Invoke",
        Effect: effect,
        Resource: resource,
      },
    ],
  };
  return {
    principalId,
    policyDocument,
    context: { uid },
  };
}

async function main(token: string) {
  const decodedToken = jwt.decode(token);
  if (easyTokenValidator(decodedToken)) {
    const iss = decodedToken.iss;
    if (iss === undefined) {
      throw new Error("Invalid token: iss is missing");
    }
    const provider = getProvider(iss);
    const validatedToken = await validateToken(token, provider);
    if (easyTokenValidator(validatedToken)) {
      return validatedToken.sub;
    }
  }
  throw new Error("Invalid token: not supported");
}

export const apiAuthorizerHandler: APIGatewayTokenAuthorizerHandler = async (
  event,
) => {
  const uid = await main(event.authorizationToken);
  return generatePolicy("user", "Allow", event.methodArn, uid);
};
