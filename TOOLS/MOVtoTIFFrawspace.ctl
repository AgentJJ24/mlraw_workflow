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
		float r_value = pow(rIn,2.2);
		float g_value = pow(gIn,2.2);
		float b_value = pow(bIn,2.2);

	//Convert to XYZ[NATIVE] from CANON MOV RGB with matrix [M]
		float base_cie_x = r_value * 0.404661618784551 + g_value * 0.350940109030372 + b_value * -0.014295785401326;
		float base_cie_y = r_value * 0.265517711285514 + g_value * 0.660567149644770 + b_value * -0.124482093011626;
		float base_cie_z = r_value * 0.021680406804885 + g_value * 0.035996508856459 + b_value * 0.726473953446277;

	//Chromatic Adaptation (None needed: WB in camera so in XZY[NATIVE])
	

	//Convert XYZ[NATIVE] to MLRAW RGB (WB'ed) (Inverse of mlraw650D_to_XYZ.spimtx)
		float base_mlR = base_cie_x * 0.557066177584223 + base_cie_y * -0.041639232190129 + base_cie_z * -0.052209516675112;
		float base_mlG = base_cie_x * -0.687965233466979 + base_cie_y * 1.427473055486480 + base_cie_z * 0.255865791845040;
		float base_mlB = base_cie_x * -0.203991170173486 + base_cie_y * 0.280656857476883 + base_cie_z * 0.638722349708797;	

	//Final Output
		rOut = base_mlR;
		gOut = base_mlG;
		bOut = base_mlB;
		aOut = 1.0;

}