echo "=====Start Copy====="

path=$(pwd)

echo "$path"

cp -f app.dart login.dart home_page.dart ../src/pages/

cd $path

cp -f main.dart ../

cd $path

cp -f conversation.dart chat.dart ../src/

cd ../src

rm -rf discuss

rm -rf channel.dart

cd ..

rm -rf openSourceTmp

rm -rf utils/discuss.dart

cd ..

rm -rf package_src

echo "=====End Copy====="

ls
