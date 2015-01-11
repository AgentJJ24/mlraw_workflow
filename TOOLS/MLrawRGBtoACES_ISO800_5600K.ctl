// CANON 650D Magic Lantern Raw RGB to ACES Transform
// Written by Joshua Jackson

void main
(	input varying float rIn,
	input varying float gIn,
	input varying float bIn,
	output varying float rOut,
	output varying float gOut,
	output varying float bOut,
	output varying float aOut)
{

	//Variable Setup
		float r_value = rIn;
		float g_value = gIn;
		float b_value = bIn;

		//ACES D60 Whitepoint
		float whitepoint_Xn = 0.95265;
		float whitepoint_Yn = 1.00000;
		float whitepoint_Zn = 1.00883;

	//Channel Mixing Matrix: Camera RGB
		//Channel Mixing Variables
			float r_r = 1;		//R-R
			float r_g = 0;		//R-G
			float r_b = 0;		//R-B
			float g_g = 1;		//G-G
			float g_r = 0;		//G-R
			float g_b = 0;		//G-B
			float b_b = 1;		//B-B
			float b_r = 0;		//B-R
			float b_g = 0;		//B-G
		//Red Channel Mixing
			r_value = (r_r * r_value) + (r_g * g_value) + (r_b * b_value);
		//Green Channel Mixing
			g_value = (g_g * g_value) + (g_r * r_value) + (g_b * b_value);
		//Blue ChannelMixing
			b_value = (b_b * b_value) + (b_g * g_value) + (b_r * r_value);


	//Convert to XYZ[D56] from RGB with matrix [M]
		float base_cie_x = r_value * 1.880505952250360 + g_value * 0.026738292324316 + b_value * 0.143002499560504;
		float base_cie_y = r_value * 0.866931536084527 + g_value * 0.772757024803404 + b_value * -0.238695282285431;
		float base_cie_z = r_value * 0.219651510889871 + g_value * -0.331012657896225 + b_value * 1.716180302041450;

	//Chromatic Adaptation (RAW XYZ[D56] --> ACES XYZ[D60])
		float aces_cie_x = 0.988857867595210 * base_cie_x + -0.005456602926280 * base_cie_y + 0.014940046678907 * base_cie_z;
		float aces_cie_y = -0.006702160333946 * base_cie_x + 1.001738529876810 * base_cie_y + 0.004969451307673 * base_cie_z;
		float aces_cie_z = 0.002908044536903 * base_cie_x + -0.004843004613791 * base_cie_y + 1.077396150073800 * base_cie_z;

	//Convert XYZ[D60] to ACES RGB
		float aces_r = ((aces_cie_x * 1.0498110175) + (aces_cie_y * 0.0000000000) + (aces_cie_z * -0.0000974845));
		float aces_g = ((aces_cie_x * -0.4959030231) + (aces_cie_y * 1.3733130458) + (aces_cie_z * 0.0982400361));
		float aces_b = ((aces_cie_x * 0.0000000000) + (aces_cie_y * 0.0000000000) + (aces_cie_z * 0.9912520182));

	//Final Output
		rOut = aces_r;
		gOut = aces_g;
		bOut = aces_b;
		aOut = 1.0;

}