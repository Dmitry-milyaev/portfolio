

clear
PS3="Enter a number: "

select config in 'Одноузловая конфигурация' 'Кластерная конфигурация'
do
    break
done

clear

select type in 'PostgreSQL' 'PostgresPRO'
do  
    break
done

clear

select version in 10 11 12 13 14
do
    break
done

clear

if [[ $config = "Одноузловая конфигурация" ]]
then(
echo "Введённые данные:"
echo "IP master -      $(hostname -i)"
echo "Версия    -      $type $version"
echo " "
)
else(
echo "Ip slave узла:"
while read ip_slave
do
   break
done
clear

echo "Виртуальный ip кластера:"
while read ip_virt
do
   break
done
clear

echo "Сетевой интерфейс - пример ens160:"
while read cluster_interface
do
   break
done
clear

echo "Маска подсети - пример 25:"
while read mask
do
   break
done
clear


echo "Введённые данные:"
echo "IP master -      $(hostname -i)"
echo "IP slave  -      $ip_slave"
echo "Виртуальный ip - $ip_virt"
echo "Версия    -      $type $version"
echo "Сетевой интерфейс - $cluster_interface"
echo "Маска подсети     - $mask"


)
fi


echo " "
select answer in 'Установить' 'Отмена'
do
    break
done

echo "$answer"
if [[ $answer = 'Установить' ]]
then
(echo "yes")
else 
(echo "no")
fi

if [[ $config = "Одноузловая конфигурация" ]]
then
  if [[ $type = "PostgreSQL" ]]
      then  echo "Postgres 1"
      else echo "PostgresPRO 1"
  fi
else
  if [[ $type = "PostgreSQL" ]]
        then  echo "Postgres 2"
        else  echo "PostgresPRO 2"
  fi       
fi      


