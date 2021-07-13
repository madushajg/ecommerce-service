rm -rf tartget
mkdir target
pushd commons
bal build -c && bal push --repository=local
popd
pushd admin
bal build
cp target/bin/admin.jar ../target
popd
pushd billing
bal build
cp target/bin/billing.jar ../target
popd
pushd cart
bal build
cp target/bin/cart.jar ../target
popd
pushd inventory
bal build
cp target/bin/inventory.jar ../target
popd
pushd ordermgt
bal build
cp target/bin/ordermgt.jar ../target
popd
pushd shipping
bal build
cp target/bin/shipping.jar ../target
popd
pushd simulator
bal build
cp target/bin/simulator.jar ../target
popd
