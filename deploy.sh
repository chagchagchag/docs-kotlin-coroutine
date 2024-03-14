echo ">>> rm -rf out"
rm -rf out

echo ""
echo ">>> rm -rf .next"
rm -rf .next

echo ""
echo ">>> yarn deploy"
yarn deploy

echo ""
echo ">>> clean"
rm -rf out
rm -rf .next