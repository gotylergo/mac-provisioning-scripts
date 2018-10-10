!/bin/bash
  
read A
if [ "$A" = "foo" ] ; then
    echo "Foo"
elif [ "$A" = "bar" ] ; then
    echo "Bar"
else
    echo "Other"
fi
