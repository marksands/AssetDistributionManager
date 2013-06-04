echo "Building Asset Distribution Manager.."

appledoc \
  --project-name "Asset Distribution Manager" \
  --project-company "Mark Sands" \
  --company-id com.asset.distributor \
  --project-version 1.0 \
  --explicit-crossref \
  --ignore ".m" \
  --keep-undocumented-objects \
  --keep-undocumented-members \
  --keep-intermediate-files \
  --no-warn-missing-arg \
  --no-warn-undocumented-object \
  --no-warn-undocumented-member \
  --no-warn-empty-description \
  --docset-bundle-id "org.adm.docset" \
  --docset-bundle-name "Asset Distribution Manager" \
  --docset-atom-filename "docset.atom" \
  --docset-feed-url "http://todo/core/feed/%DOCSETATOMFILENAME" \
  --docset-package-url "http://todo/core/feed/%DOCSETPACKAGEFILENAME" \
  --publish-docset \
  --output . \
  ../src/Classes/ADM*

echo
echo "Finished."
