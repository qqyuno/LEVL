"use client";

// Pure CSS animated lines — zero GPU overhead, visually similar to the WebGL shader
export default function ShaderLines({ style, className, opacity = 0.7 }: {
  style?: React.CSSProperties;
  className?: string;
  opacity?: number;
}) {
  return (
    <div className={className} style={{ width: "100%", height: "100%", opacity, overflow: "hidden", ...style }}>
      <style>{`
        @keyframes shaderSlide {
          0%   { transform: translateX(-100%); }
          100% { transform: translateX(100vw); }
        }
        .shader-line {
          position: absolute;
          top: 0; bottom: 0;
          width: 2px;
          animation: shaderSlide linear infinite;
          opacity: 0.6;
        }
      `}</style>

      {[
        { left: "8%",  color: "#3B82F6", dur: "8s",  delay: "0s" },
        { left: "18%", color: "#8B5CF6", dur: "11s", delay: "-3s" },
        { left: "30%", color: "#06B6D4", dur: "7s",  delay: "-1.5s" },
        { left: "42%", color: "#3B82F6", dur: "13s", delay: "-6s" },
        { left: "54%", color: "#A855F7", dur: "9s",  delay: "-2s" },
        { left: "65%", color: "#06B6D4", dur: "6s",  delay: "-4s" },
        { left: "74%", color: "#3B82F6", dur: "10s", delay: "-0.5s" },
        { left: "85%", color: "#8B5CF6", dur: "12s", delay: "-7s" },
      ].map((l, i) => (
        <div
          key={i}
          className="shader-line"
          style={{
            left: l.left,
            background: `linear-gradient(to bottom, transparent, ${l.color}, transparent)`,
            boxShadow: `0 0 8px 2px ${l.color}55`,
            animationDuration: l.dur,
            animationDelay: l.delay,
          }}
        />
      ))}
    </div>
  );
}
