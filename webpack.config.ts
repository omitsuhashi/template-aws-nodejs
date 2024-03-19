import path from "node:path";
import CopyPlugin from "copy-webpack-plugin";
import { WebpackConfiguration } from "webpack-cli";
import webpackNodeExternals from "webpack-node-externals";

const isDev = process.env.NODE_ENV === "dev";

const prismaCopy = new CopyPlugin({
  patterns: [
    {
      from: "./node_modules/.prisma/client",
      to: "./node_modules/.prisma/client/",
      filter: (filepath) => /\.(so\.node|prisma)$/.test(filepath),
    },
  ],
});

const baseConfig: WebpackConfiguration = {
  mode: isDev ? "development" : "production",
  target: "node",
  module: {
    rules: [
      {
        test: /\.ts?$/,
        use: "ts-loader",
        exclude: /node_modules/,
      },
    ],
  },
  resolve: {
    extensions: [".tsx", ".ts", ".js"],
  },
  output: {
    filename: "index.js",
    path: path.resolve(__dirname, "dist"),
    libraryTarget: "commonjs2",
  },
};

if (isDev) {
  baseConfig.externals = [];
  baseConfig.plugins = [prismaCopy];
} else {
  baseConfig.externals = [
    webpackNodeExternals({
      // バンドルに含めるモジュールを指定
      allowlist: ["zod", "http-status-codes"],
    }),
  ];
  baseConfig.optimization = {
    minimize: true,
  };
}

module.exports = baseConfig;
