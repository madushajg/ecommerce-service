rm -rf tartget
mkdir target
pushd commons
bal build -c && bal push --repository=local
popd
pushd admin
bal build
mv target/bin/admin.jar ../target
popd
pushd billing
bal build
mv target/bin/billing.jar ../target
popd
pushd cart
bal build
mv target/bin/cart.jar ../target
popd
pushd inventory
bal build
mv target/bin/inventory.jar ../target
popd
pushd ordermgt
bal build
mv target/bin/ordermgt.jar ../target
popd
pushd shipping
bal build
mv target/bin/shipping.jar ../target
popd
pushd simulator
bal build
mv target/bin/simulator.jar ../target
popd
