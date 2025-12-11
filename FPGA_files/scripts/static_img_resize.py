# This script basically resizes an image to be compatible with out display and makes a coe file that can be loaded on to the 
# ROM of the FPGA

from PIL import Image
import os

def generate_coe_from_image(input_filename="UVCE_-_Library.png", output_filename="image.coe"):
    # Check if image exists
    if not os.path.exists(input_filename):
        print(f"ERROR: Could not find '{input_filename}'.")
        print("Please save your photo as 'input.jpg' in this folder and try again.")
        return

    # Load the image
    img = Image.open(input_filename)
    
    # 1. Resize to 80x60
    #    Why? Because 640x480 screen / 8 scaling = 80x60.
    #    This fits perfectly inside your 100x100 memory block.
    img = img.resize((80, 60), Image.Resampling.LANCZOS)
    
    # 2. Create the 100x100 canvas (matching your IP Core configuration)
    #    Background is black for the unused memory area.
    canvas = Image.new("RGB", (100, 100), (0, 0, 0))
    
    # 3. Paste the resized image at (0,0)
    canvas.paste(img, (0, 0))
    
    # 4. Generate COE data
    pixels = list(canvas.getdata())
    
    with open(output_filename, "w") as f:
        f.write("memory_initialization_radix=16;\n")
        f.write("memory_initialization_vector=\n")
        
        for i, px in enumerate(pixels):
            # Convert 8-bit RGB to 12-bit color (R4 G4 B4)
            # We take the top 4 bits of each color channel
            val = ((px[0] >> 4) << 8) | ((px[1] >> 4) << 4) | (px[2] >> 4)
            
            # Formatting: semicolons for the last item, commas for others
            end = ",\n" if i < len(pixels) - 1 else ";\n"
            f.write(f"{val:03X}{end}")

    print(f"Done! Generated {output_filename} from {input_filename}.")
    print("Dimensions: Resized to 80x60, padded to 100x100.")

if __name__ == "__main__":
    generate_coe_from_image()