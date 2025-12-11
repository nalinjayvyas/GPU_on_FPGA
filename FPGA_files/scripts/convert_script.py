from PIL import Image

# Use any image, ideally 64px wide x 256px high (4 frames of 64x64 stacked)
# If you don't have one, just use a random 64x256 image to test.
IMG_NAME = "charizard_strip.png" 
OUT_NAME = "sprite.coe"

def main():
    try:
        img = Image.open(IMG_NAME).convert("RGB")
        img = img.resize((64, 256)) # Force correct size
        
        with open(OUT_NAME, "w") as f:
            f.write("memory_initialization_radix=16;\n")
            f.write("memory_initialization_vector=\n")
            
            pixels = list(img.getdata())
            for i, px in enumerate(pixels):
                # Convert to 12-bit color (R4 G4 B4)
                val = ((px[0]>>4) << 8) | ((px[1]>>4) << 4) | (px[2]>>4)
                end = ",\n" if i < len(pixels)-1 else ";\n"
                f.write(f"{val:03X}{end}")
                
        print(f"Success! {OUT_NAME} created.")
    except Exception as e:
        print(f"Error: {e}")

if __name__ == "__main__":
    main()