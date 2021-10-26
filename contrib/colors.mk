# Reset
Color_Off=\033[0m

# Regular Colors
Black=\033[0;30m
Red=\033[0;31m
Green=\033[0;32m
Yellow=\033[0;33m
Blue=\033[0;34m
Purple=\033[0;35m
Cyan=\033[0;36m
White=\033[0;37m

# Bold
BBlack=\033[1;30m
BRed=\033[1;31m
BGreen=\033[1;32m
BYellow=\033[1;33m
BBlue=\033[1;34m
BPurple=\033[1;35m
BCyan=\033[1;36m
BWhite=\033[1;37m

# Underline
UBlack=\033[4;30m
URed=\033[4;31m
UGreen=\033[4;32m
UYellow=\033[4;33m
UBlue=\033[4;34m
UPurple=\033[4;35m
UCyan=\033[4;36m
UWhite=\033[4;37m

# Background
On_Black=\033[40m
On_Red=\033[41m
On_Green=\033[42m
On_Yellow=\033[43m
On_Blue=\033[44m
On_Purple=\033[45m
On_Cyan=\033[46m
On_White=\033[47m

# High Intensity
IBlack=\033[0;90m
IRed=\033[0;91m
IGreen=\033[0;92m
IYellow=\033[0;93m
IBlue=\033[0;94m
IPurple=\033[0;95m
ICyan=\033[0;96m
IWhite=\033[0;97m

# Bold High Intensity
BIBlack=\033[1;90m
BIRed=\033[1;91m
BIGreen=\033[1;92m
BIYellow=\033[1;93m
BIBlue=\033[1;94m
BIPurple=\033[1;95m
BICyan=\033[1;96m
BIWhite=\033[1;97m

# High Intensity backgrounds
On_IBlack=\033[0;100m
On_IRed=\033[0;101m
On_IGreen=\033[0;102m
On_IYellow=\033[0;103m
On_IBlue=\033[0;104m
On_IPurple=\033[0;105m
On_ICyan=\033[0;106m
On_IWhite=\033[0;107m


.show_colors:
	@echo -e Black = "$(Black)Black$(Color_Off)"
	@echo -e Red = "$(Red)Red$(Color_Off)"
	@echo -e Green = "$(Green)Green$(Color_Off)"
	@echo -e Yellow = "$(Yellow)Yellow$(Color_Off)"
	@echo -e Blue = "$(Blue)Blue$(Color_Off)"
	@echo -e Purple = "$(Purple)Purple$(Color_Off)"
	@echo -e Cyan = "$(Cyan)Cyan$(Color_Off)"
	@echo -e White = "$(White)White$(Color_Off)"

	@echo -e BBlack = "$(BBlack)BBlack$(Color_Off)"
	@echo -e BRed = "$(BRed)BRed$(Color_Off)"
	@echo -e BGreen = "$(BGreen)BGreen$(Color_Off)"
	@echo -e BYellow = "$(BYellow)BYellow$(Color_Off)"
	@echo -e BBlue = "$(BBlue)BBlue$(Color_Off)"
	@echo -e BPurple = "$(BPurple)BPurple$(Color_Off)"
	@echo -e BCyan = "$(BCyan)BCyan$(Color_Off)"
	@echo -e BWhite = "$(BWhite)BWhite$(Color_Off)"

	@echo -e IBlack = "$(IBlack)IBlack$(Color_Off)"
	@echo -e IRed = "$(IRed)IRed$(Color_Off)"
	@echo -e IGreen = "$(IGreen)IGreen$(Color_Off)"
	@echo -e IYellow = "$(IYellow)IYellow$(Color_Off)"
	@echo -e IBlue = "$(IBlue)IBlue$(Color_Off)"
	@echo -e IPurple = "$(IPurple)IPurple$(Color_Off)"
	@echo -e ICyan = "$(ICyan)ICyan$(Color_Off)"
	@echo -e IWhite = "$(IWhite)IWhite$(Color_Off)"

	@echo -e BIBlack = "$(BIBlack)BIBlack$(Color_Off)"
	@echo -e BIRed = "$(BIRed)BIRed$(Color_Off)"
	@echo -e BIGreen = "$(BIGreen)BIGreen$(Color_Off)"
	@echo -e BIYellow = "$(BIYellow)BIYellow$(Color_Off)"
	@echo -e BIBlue = "$(BIBlue)BIBlue$(Color_Off)"
	@echo -e BIPurple = "$(BIPurple)BIPurple$(Color_Off)"
	@echo -e BICyan = "$(BICyan)BICyan$(Color_Off)"
	@echo -e BIWhite = "$(BIWhite)BIWhite$(Color_Off)"

	@echo -e UBlack = "$(UBlack)UBlack$(Color_Off)"
	@echo -e URed = "$(URed)URed$(Color_Off)"
	@echo -e UGreen = "$(UGreen)UGreen$(Color_Off)"
	@echo -e UYellow = "$(UYellow)UYellow$(Color_Off)"
	@echo -e UBlue = "$(UBlue)UBlue$(Color_Off)"
	@echo -e UPurple = "$(UPurple)UPurple$(Color_Off)"
	@echo -e UCyan = "$(UCyan)UCyan$(Color_Off)"
	@echo -e UWhite = "$(UWhite)UWhite$(Color_Off)"

	@echo -e On_Black = "$(On_Black)On_Black$(Color_Off)"
	@echo -e On_Red = "$(On_Red)On_Red$(Color_Off)"
	@echo -e On_Green = "$(On_Green)On_Green$(Color_Off)"
	@echo -e On_Yellow = "$(On_Yellow)On_Yellow$(Color_Off)"
	@echo -e On_Blue = "$(On_Blue)On_Blue$(Color_Off)"
	@echo -e On_Purple = "$(On_Purple)On_Purple$(Color_Off)"
	@echo -e On_Cyan = "$(On_Cyan)On_Cyan$(Color_Off)"
	@echo -e On_White = "$(On_White)On_White$(Color_Off)"

	@echo -e On_IBlack = "$(On_IBlack)On_IBlack$(Color_Off)"
	@echo -e On_IRed = "$(On_IRed)On_IRed$(Color_Off)"
	@echo -e On_IGreen = "$(On_IGreen)On_IGreen$(Color_Off)"
	@echo -e On_IYellow = "$(On_IYellow)On_IYellow$(Color_Off)"
	@echo -e On_IBlue = "$(On_IBlue)On_IBlue$(Color_Off)"
	@echo -e On_IPurple = "$(On_IPurple)On_IPurple$(Color_Off)"
	@echo -e On_ICyan = "$(On_ICyan)On_ICyan$(Color_Off)"
	@echo -e On_IWhite = "$(On_IWhite)On_IWhite$(Color_Off)"
