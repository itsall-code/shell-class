#!/bin/bash
#一个综合应用脚本程序

# 安装必备工具
function init {
	case $1 in
		1 )
			sudo apt-get install bc dialog;;
		2 )
			sudo dnf install bc dialog;;
		# 其他Linux发行版的包管理工具可以自行添加
		* )
			echo "程序退出成功"
			exit 0;;
	esac
}

# 检测是否有安装bc与dialog包，若无将通无法运行该脚本，将进行安装
which bc dialog
if [[ $?  -ne 0 ]]; then
	echo "即将安装dialog"
	echo "1. Debian "
	echo "2. Red Hat "
	echo "3. 退出安装 "
	read -p "请选择您的系统发行版本：" sys
	init $sys
fi

# 使用mktemp生成临时文件进行程序的临时数据记录
# 负责记录综合应用菜单（主菜单）的选择
mian_select=`mktemp main_select.XXXXXX`
# 负责记录shell命令类别的选择
commands_select=`mktemp commands_select.XXXXXX`
# 负责记录剪刀石头布的玩家出拳
stonegame_select=`mktemp stonegame_select.XXXXXX`
# 负责记录计算器的选择
calculator_select=`mktemp calculator_select.XXXXXX`

# 负责记录计算数字
number=`mktemp number.XXXXXX`

# 打印常用的shell命令的代码块-开始
function commands_menu {
	# 该函数负责打印类别的选择，一共8大类
	# 通过dialog的menu选择需要打印的shell命令
	dialog --title "常用shell命令"\
		 --menu "请您选择需要查看的手册" 11 44 10\
		 	 1 "文件、目录操作命令"\
		 	 2 "查看文件内容命令"\
		 	 3 "基本系统命令"\
		 	 4 "监视系统状态命令"\
		 	 5 "磁盘操作命令"\
		 	 6 "用户和组相关命令"\
		 	 7 "压缩命令"\
		 	 8 "网络相关命令" 2> $commands_select # 重定向覆盖
}

function commands_endtxt {
	# 该函数负责退出打印手册的信息
	# 使用dialog的msgbox实现
	dialog --title "常用shell命令"\
		 --msgbox " \n\n\n手册查询结束，感谢您的使用！"\
		 	 11 44
}

function commands_out {
	# 该函数负责打印shell手册
	# 使用dialog的textbox输出选择的shell命令手册
	# 每一类都放在shell1～8.txt文件中
	n=`cat $commands_select` # 读取在commands_menu选择的值
	dialog --title "常用shell命令"\
		--textbox ./doc/shell$n.txt 20 50
		# 输出储存在shelln.txt文件中的shell，n为类别号
}

function shell_commands {
	# 该函数为打印常见shell命令的功能入口
	while [[ 1 ]]; do
		commands_menu
		# 若在commands_menu中选择取消，
		# 则会返回1值，此时退出打印功能，并提醒用户
		if [[ $? -eq 1 ]]; then
			commands_endtxt
			break
		fi
		commands_out
	done
}
# 打印常用的shell命令的代码块-结束

# 石头剪刀布的代码块-开始
function stonegame_menu {
	# 该函数负责游戏主菜单
	# 使用dialog的menu进行出拳选择
	dialog --title "石头剪刀布"\
		 --menu "请您出拳：" 11 44 10\
			 1 "石头"\
			 2 "剪刀"\
			 3 "布" 2> $stonegame_select #选择结果重定向
}

function stonegame_endtxt {
	# 该函数负责游戏结束信息提醒
	# 使用dialog的msgbox进行信息输出
	dialog --title "石头剪刀布"\
		 --msgbox " \n\n\n游戏结束，感谢您的使用！"\
		 11 44
}

function stonegame_play {
	# 该函数负责游戏的输赢逻辑判断
	# 接受3个参数，$1为玩家出拳信息，$2为电脑
	# $3为游戏得分
	card_lib=("石头" "剪刀" "布")
	# 重定向覆盖游戏信息
	echo "您出${card_lib[$1-1]}" > gametxt
	# 重定向追加
	echo "电脑出${card_lib[$2-1]}" >> gametxt
	# 逻辑判断
	# 石头为1, 遇到剪刀2才能赢，$3为 1 - 2 = -1
	# 遇到布3输，$3为 1 - 3 = -2,
	# 同理推出输赢表 $1 $2 $3 游戏结果
	# 1 1 0 平局		2 1 1 电脑赢		3 1 2 玩家赢
	# 1 2 -1 玩家赢  2 2 0 平局		3 2 1 电脑赢
	# 1 3 -2 电脑赢  2 3 -1 玩家赢	3 3 0 平局
	case $3 in
		-1 | 2 )
			echo "您赢了" >> gametxt;;
		1 | -2 )
			echo "电脑赢了" >> gametxt;;
		0 )
			echo "平局" >> gametxt;;
	esac
}

function stonegame_out {
	# 该函数负责输出游戏结果
	dialog --title "石头剪刀布"\
		 --textbox gametxt 11 44
}

function shell_stonegame {
	# 该函数为石头剪刀布游戏入口
	# 调用函数完成功能
	while [[ 1 ]]; do
		clear
		stonegame_menu
		# 如果在stonegame_menu函数中选择取消，
		# 则dialog会返回1,视为退出游戏
		if [[ $? -eq 1 ]]; then
			stonegame_endtxt
			break
		fi
		# 读取stonegame_menu函数选择数值，生成玩家的出拳
		player=`cat $stonegame_select`
		# 产生1~3的随机数，模拟电脑出拳
		computer=$[RANDOM%3+1]
		# score判断计分
		score=$[$player-$computer]
		stonegame_play $player $computer $score
		stonegame_out
	done
}
# 石头剪刀布的代码块-结束

# 加减计算器的代码块-开始
# 加减计算器的菜单
function calculator_menu {
	dialog --title "加减乘除计算器"\
		 --menu "请您填充好数据与运算符,再进行计算" 11 44 10\
		 1 "操作数1"\
		 2 "运算符"\
		 3 "操作数2"\
		 4 "计算结果" 2> $calculator_select
}

# 结束信息提醒
function calculator_endtxt {
	dialog --title "加减乘除计算器"\
		 --msgbox " \n\n\n计算器已成功关闭" 11 44
}

# 数字初始化
function scanner_number {
	dialog --title "加减乘除计算器"\
		 --inputbox "请输入一个数"\
		 11 44 2> $number # 
	num=`cat $number`
	if [[ $num =~ ^([0-9]*|d*.d{1}?d*)$ ]]; then
		case $1 in
		1 )
			echo "$num" > calculator_number1;;
		2 )
			echo "$num" > calculator_number2;;
		esac
	else
		dialog --title "加减乘除计算器"\
			--msgbox " \n\n\n您输出的不是数字" 11 44
	fi
}

# 选择运算符
function scanner_operator {
	dialog --title "加减乘除计算器"\
		 --menu "请选择运算符" 11 44 10\
		 1 "加号 +"\
		 2 "减号 -"\
		 3 "乘号 ×"\
		 4 "除号 /" 2> calculator_operator
}

# 计算器运行
function run {
	clib=('+' '-' 'x' '/')
	number1=`cat calculator_number1`
	number2=`cat calculator_number2`
	operator=`cat calculator_operator`
	echo "$number1 ${clib[operator-1]} $number2 的结果为：" > numtxt
	case $operator in
		1 )
			echo "scale=2;$number1+$number2" | bc >> numtxt;;
		2 )
			echo "scale=2;$number1-$number2" | bc >> numtxt;;
		3 )
			echo "scale=2;$number1*$number2" | bc >> numtxt;;
		4 )
			echo "scale=2;$number1/$number2" | bc >> numtxt;;
	esac
	dialog --title "加减乘除计算器"\
	 	 --textbox numtxt 11 44
}

# 数据初始化
function calculator_init {
	selection=`cat $calculator_select`
	case $selection in
		1 )
			scanner_number 1;;
		2 )
			scanner_operator;;
		3 )
			scanner_number 2;;
		4 )
			run;;
	esac
}

function shell_calculator {
	#该函数为计算器入口
	echo "0" > calculator_number1
	echo "0" > calculator_number2
	echo "1" > calculator_operator
	while [[ 1 ]]; do
		clear
		calculator_menu
		if [[ $? -eq 1 ]]; then
		calculator_endtxt
		break
		fi
		calculator_init
	done
}
# 加减乘除计算器的代码块-结束

# 主程序菜单
function mian_menu {
	dialog --title "综合应用脚本程序"\
	 --menu "请选择功能：" 10 44 10\
		 1 "打印shell命令"\
		 2 "石头剪刀布游戏"\
		 3 "加减乘除计算器" 2> $mian_select
}

# 主要的运行
mainRunopen=1
while [[ $mainRunopen -eq 1 ]]; do
	clear
	mian_menu
	MS=`cat $mian_select`
	case $MS in
	1)
		shell_commands;;
	2)
		shell_stonegame;;
	3)
		shell_calculator;;
	*)
		dialog --msgbox " \n\n\n退出成功，感谢您的使用！"\
			 11 44
		mainRunopen=0
		break;;
	esac
done

# rm -f $ 2> /dev/null
rm -f $mian_select 2> /dev/null
rm -f $commands_select 2> /dev/null
rm -f $stonegame_select 2> /dev/null
rm -f $calculator_select 2> /dev/null
rm -f gametxt 2> /dev/null
rm -f $number 2> /dev/null
rm -f calculator_number1 2> /dev/null
rm -f calculator_number2 2> /dev/null
rm -f calculator_operator 2> /dev/null
rm -f numtxt 2> /dev/null
# 确保退出时执行所有清理操作
exit 0
