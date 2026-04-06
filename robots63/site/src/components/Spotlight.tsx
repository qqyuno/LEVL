"use client";

import React from "react";

interface SpotlightProps {
  className?: string;
  fill?: string;
  style?: React.CSSProperties;
}

export function Spotlight({ className = "", fill = "white", style }: SpotlightProps) {
  return (
    <svg
      className={className}
      style={{ position: "absolute", pointerEvents: "none", zIndex: 0, ...style }}
      xmlns="http://www.w3.org/2000/svg"
      viewBox="0 0 3787 2842"
      fill="none"
    >
      <g filter="url(#filter)">
        <ellipse
          cx="1924.71"
          cy="273.501"
          rx="1924.71"
          ry="273.501"
          transform="matrix(-0.822377 -0.568943 -0.568943 0.822377 3631.88 2291.09)"
          fill={fill}
          fillOpacity="0.21"
        />
      </g>
      <defs>
        <filter id="filter" x="0.860352" y="0.838989" width="3785.16" height="2840.26"
          filterUnits="userSpaceOnUse" colorInterpolationFilters="sRGB">
          <feFlood floodOpacity="0" result="BackgroundImageFix" />
          <feBlend mode="normal" in="SourceGraphic" in2="BackgroundImageFix" result="shape" />
          <feGaussianBlur stdDeviation="151" result="effect1_foregroundBlur" />
        </filter>
      </defs>
    </svg>
  );
}

// Mouse-following spotlight for interactive use
export function MouseSpotlight() {
  return (
    <div
      style={{
        position: "absolute",
        inset: 0,
        overflow: "hidden",
        pointerEvents: "none",
      }}
      onMouseMove={(e) => {
        const el = e.currentTarget as HTMLDivElement;
        const rect = el.getBoundingClientRect();
        el.style.setProperty("--mx", `${e.clientX - rect.left}px`);
        el.style.setProperty("--my", `${e.clientY - rect.top}px`);
      }}
    >
      <div
        style={{
          position: "absolute",
          width: 700,
          height: 700,
          borderRadius: "50%",
          background: "radial-gradient(circle, rgba(161,98,7,0.12) 0%, rgba(161,98,7,0.04) 40%, transparent 70%)",
          left: "var(--mx, 50%)",
          top: "var(--my, 40%)",
          transform: "translate(-50%, -50%)",
          transition: "left 0.4s ease, top 0.4s ease",
          pointerEvents: "none",
        }}
      />
    </div>
  );
}

export default MouseSpotlight;
