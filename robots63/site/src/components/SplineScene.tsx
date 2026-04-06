"use client";

import { Suspense, lazy } from "react";

const Spline = lazy(() => import("@splinetool/react-spline"));

interface Props {
  scene: string;
  className?: string;
  style?: React.CSSProperties;
}

export default function SplineScene({ scene, className, style }: Props) {
  return (
    <Suspense
      fallback={
        <div style={{ width: "100%", height: "100%", display: "flex", alignItems: "center", justifyContent: "center" }}>
          <div style={{
            width: 48, height: 48, borderRadius: "50%",
            border: "2px solid rgba(161,98,7,0.3)",
            borderTopColor: "#A16207",
            animation: "spin 1s linear infinite",
          }} />
          <style>{`@keyframes spin{to{transform:rotate(360deg)}}`}</style>
        </div>
      }
    >
      <Spline scene={scene} className={className} style={style} />
    </Suspense>
  );
}
