#!/bin/bash
cd D:/VirtualC/studyFlow
git remote remove origin 2>/dev/null
git remote add origin https://github.com/yomonzhou-prog/StudyFlow.git
git push -u origin main
echo "Done! Check https://github.com/yomonzhou-prog/StudyFlow"
