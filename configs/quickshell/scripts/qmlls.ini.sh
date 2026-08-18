if [ -f "../.qmlls.ini" ]; then
  echo "File exists.";
else
  touch ../.qmlls.ini
  echo "Created .qmlls.ini"
fi
