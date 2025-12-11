# This code generates a simple pixel art sprite strip of a dragon character

from PIL import Image, ImageDraw

# Configuration
WIDTH = 64
HEIGHT = 64
FRAMES = 4
OUT_FILE = "charizard_strip.png"

# Charizard Palette (Approximation)
COLOR_SKIN = (255, 140, 0)   # Orange
COLOR_BELLY = (255, 220, 150) # Light Yellow
COLOR_WING_IN = (40, 100, 100) # Teal/Green
COLOR_WING_OUT = (200, 50, 0) # Dark Orange
COLOR_FLAME = (255, 0, 0)     # Red
COLOR_BG = (0, 0, 0)          # Black (Transparency Key)

def draw_dragon(draw, offset_y, frame_idx):
    # Calculate "Bobbing" animation offset
    bob = 0
    if frame_idx == 1: bob = -2
    if frame_idx == 2: bob = 0
    if frame_idx == 3: bob = 2
    
    # Base coordinates (Centered in 64x64)
    cx, cy = 32, 40 + bob
    
    # 1. Wings (Simple Flap logic)
    wing_y = cy - 10
    if frame_idx % 2 == 0: wing_y -= 5 # Flap up
    
    # Left Wing
    draw.polygon([(cx-5, cy-5), (cx-25, wing_y), (cx-10, cy+5)], fill=COLOR_WING_IN, outline=COLOR_WING_OUT)
    # Right Wing
    draw.polygon([(cx+5, cy-5), (cx+25, wing_y), (cx+10, cy+5)], fill=COLOR_WING_IN, outline=COLOR_WING_OUT)

    # 2. Tail & Flame
    draw.line([(cx, cy+10), (cx+15, cy+15), (cx+20, cy+5)], fill=COLOR_SKIN, width=5)
    # Flame flickers based on frame
    flame_r = 6 if frame_idx % 2 == 0 else 4
    draw.ellipse([cx+18-flame_r, cy+3-flame_r, cx+18+flame_r, cy+3+flame_r], fill=COLOR_FLAME)

    # 3. Body (Oval)
    draw.ellipse([cx-12, cy-15, cx+12, cy+15], fill=COLOR_SKIN)
    # Belly
    draw.ellipse([cx-8, cy-10, cx+8, cy+15], fill=COLOR_BELLY)

    # 4. Head
    head_y = cy - 20
    draw.ellipse([cx-9, head_y-12, cx+9, head_y+5], fill=COLOR_SKIN)
    
    # Eyes
    draw.rectangle([cx-5, head_y-5, cx-3, head_y-3], fill=(0,0,0))
    draw.rectangle([cx+3, head_y-5, cx+5, head_y-3], fill=(0,0,0))

    # 5. Legs
    draw.ellipse([cx-10, cy+10, cx-2, cy+18], fill=COLOR_SKIN) # Left
    draw.ellipse([cx+2, cy+10, cx+10, cy+18], fill=COLOR_SKIN) # Right

    # 6. Arms
    arm_y = cy - 5
    if frame_idx % 2 != 0: arm_y -= 3 # Swing arms
    draw.ellipse([cx-16, arm_y, cx-10, arm_y+6], fill=COLOR_SKIN)
    draw.ellipse([cx+10, arm_y, cx+16, arm_y+6], fill=COLOR_SKIN)

def main():
    # Create the full strip (64 width x 256 height)
    full_img = Image.new("RGB", (WIDTH, HEIGHT * FRAMES), COLOR_BG)
    draw = ImageDraw.Draw(full_img)

    for i in range(FRAMES):
        # Calculate top-left Y position for this frame
        y_pos = i * HEIGHT
        draw_dragon(draw, y_pos, i)

    # Save
    full_img.save(OUT_FILE)
    print(f"Generated {OUT_FILE} (64x256).")
    print("Now run your conversion script on this file!")

if __name__ == "__main__":
    main()