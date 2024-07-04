#!/bin/bash

# Start time
start=$(date +%s)

rm errs.txt
touch errs.txt
rm ./noposts.txt
rm ./comments-got.txt ./comments-errs.txt ./comments-retry.txt

for ((i = 0; i < 100; i++)); do
	python ./subreddit/subreddits.py && break
	echo "Retrying.."
	notify-send "Retrying subreddits..."
	echo "Retrying subreddits ${i+1} ..." >>errs.txt
	sleep 10
done

for ((i = 0; i < 100; i++)); do
	python ./post/posts.py && break
	echo "Retrying.."
	notify-send "Retrying posts..."
	echo "Retrying posts ${i+1} ..." >>errs.txt
	rm ./noposts.txt
	sleep 10
done

for ((i = 0; i < 100; i++)); do
	python ./user/users.py && break
	echo "Retrying.."
	notify-send "Retrying users..."
	echo "Retrying users ${i+1} ..." >>errs.txt
	sleep 10
done

### Split Files into chunks for easy importing
python split.py
mkdir json
mv *.json json/

### Import data into mongodb
mongosh --eval "use reddit" --eval "db.dropDatabase()"
mongosh --eval "use reddit"

# Cluster URI
# CLUSTER_URI=$(echo -e '')
# mongoimport -d socialmedia -c subreddits --file ./subreddits.json --jsonArray --uri "${CLUSTER_URI}"
# mongoimport -d socialmedia -c posts --file ./posts.json --jsonArray --uri "${CLUSTER_URI}"
# mongoimport -d socialmedia -c users --file ./users.json --jsonArray --uri "${CLUSTER_URI}"

# Local import
# mongoimport -d reddit -c subreddits --file ./subreddits_p1.json --jsonArray
# mongoimport -d reddit -c posts --file ./posts_p1.json --jsonArray
# mongoimport -d reddit -c users --file ./user_p1.json --jsonArray
# mongoimport -d reddit -c users --file ./user_p2.json --jsonArray

# End time
end=$(date +%s)

# Calculate the duration in seconds
duration=$((end - start))

# Convert seconds to days, hours, minutes, and seconds
days=$((duration / 86400))
hours=$(((duration % 86400) / 3600))
minutes=$(((duration % 3600) / 60))
seconds=$((duration % 60))

# Display the duration
echo "####### TIME TAKEN #######"
echo ""
echo "Execution time: $days days, $hours hours, $minutes minutes, $seconds seconds"
echo ""
echo "####### TIME TAKEN #######"
