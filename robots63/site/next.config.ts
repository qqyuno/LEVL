import type { NextConfig } from "next";
import path from "path";

const nextConfig: NextConfig = {
  turbopack: {
    root: path.resolve(__dirname),
  },

  async headers() {
    return [
      {
        source: "/(.*)",
        headers: [
          { key: "X-Frame-Options", value: "SAMEORIGIN" },
          { key: "X-Content-Type-Options", value: "nosniff" },
          { key: "Referrer-Policy", value: "strict-origin-when-cross-origin" },
          { key: "Strict-Transport-Security", value: "max-age=63072000; includeSubDomains; preload" },
          { key: "Permissions-Policy", value: "camera=(), microphone=(), geolocation=()" },
          { key: "Content-Security-Policy", value: "default-src 'self'; script-src 'self' 'unsafe-inline' 'unsafe-eval' https://unpkg.com; style-src 'self' 'unsafe-inline' https://fonts.googleapis.com; img-src 'self' data: blob: https:; frame-src https://www.youtube.com https://prod.spline.design; font-src 'self' https://fonts.gstatic.com; connect-src 'self' https:; worker-src 'self' blob:;" },
        ],
      },
    ];
  },

  async redirects() {
    return [
      { source: "/catalog/deep-robotics-s20-w", destination: "/catalog/deep-robotics-x30", permanent: true },
    ];
  },

  images: {
    remotePatterns: [
      { protocol: "https", hostname: "shop.unitree.com" },
      { protocol: "https", hostname: "www.unitree.com" },
      { protocol: "https", hostname: "oss-global-cdn.unitree.com" },
      { protocol: "https", hostname: "www.agibot.com" },
      { protocol: "https", hostname: "owebsite-cdn.ubtrobot.com" },
    ],
  },
};

export default nextConfig;
