::ModMathRun <- {
	ID = "mod_math_run",
	Name = "ModMathRun",
	Version = "1.0.0",
	// Modern Hooks Object
	MH = null,
	// MSU Object
	Mod = null,
}
// Instantiate the Modern Hooks object, add MSU as a requirement, and queue after MSU
// https://bbmodding.enduriel.com/docs/modern-hooks/mod-object/
::ModMathRun.MH = ::Hooks.register(::ModMathRun.ID, ::ModMathRun.Version, ::ModMathRun.Name);
::ModMathRun.MH.require("mod_msu");
::ModMathRun.MH.queue(">mod_msu", function(){
	// Instantiate the MSU Object
	// https://github.com/MSUTeam/MSU/wiki/Mod
	::ModMathRun.Mod = ::MSU.Class.Mod(::ModMathRun.ID, ::ModMathRun.Version, ::ModMathRun.Name);

	// Includes the 'load' file of your private folder
	// Within this file, you can execute things or load more files (such as hooks)
	// as to better organise your mod, not clutter this file, and load things in order
	::include("mod_math_run/load.nut")
});