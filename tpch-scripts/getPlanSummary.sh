#!/bin/bash
# USAGE:create summary of the json plan.
# Argument: directory containing all the plan files. The assumption is that the plan filenames start with plan_, if not make appropriate changes.

if [ ! -d "PlanSummarizer" ]; then
	git clone https://github.com/dharmeshkakadia/PlanSummarizer 
  ../apache-maven-*/bin/mvn package assembly:single -f PlanSummarizer/pom.xml
fi

while IFS= read -r -d $'\0' file; do
        java -jar PlanSummarizer/target/plansummarizer.jar $file > ${file/plan_*_query/plan_summary_q}
done < <(find $1 -name "plan_*" -type f -print0)
