package gryffin.core;

#if android
	typedef SystemKernel = gryffin.core.kernel.AndroidKernel;
#elseif linux
	typedef SystemKernel = gryffin.core.kernel.LinuxKernel;
#elseif html5
	typedef SystemKernel = gryffin.core.kernel.BrowserKernel;
#else
	typedef SystemKernel = gryffin.core.kernel.GenericKernel;
#end