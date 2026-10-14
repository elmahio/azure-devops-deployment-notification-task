"use strict";

// Azure Pipelines passes task inputs as INPUT_<NAME> environment variables.
const input = (name) => (process.env["INPUT_" + name.toUpperCase()] || "").trim();

const fail = (message) => {
  console.log("##vso[task.logissue type=error]" + message);
  console.log("##vso[task.complete result=Failed;]" + message);
  process.exitCode = 1;
};

async function run() {
  const apiKey = input("apiKey");
  if (!apiKey) {
    fail("Input required: apiKey");
    return;
  }
  console.log("##vso[task.setsecret]" + apiKey);

  const logId = input("logId");
  let version = input("version");
  let description = "";
  let userName = "";
  let userEmail = "";

  const env = process.env;
  if (env.RELEASE_RELEASENAME) {
    version = version || env.RELEASE_RELEASENAME;
    description = env.RELEASE_RELEASEDESCRIPTION || "";
    userName = env.RELEASE_REQUESTEDFOR || "";
  } else {
    version = version || env.BUILD_BUILDNUMBER || "";
    description = env.BUILD_SOURCEVERSIONMESSAGE || "";
    userName = env.BUILD_SOURCEVERSIONAUTHOR || "";
    userEmail = env.BUILD_SOURCEVERSIONAUTHOREMAIL || "";
  }

  const body = new URLSearchParams({ version, description, userName, userEmail, logId });
  const url = "https://api.elmah.io/v3/deployments?api_key=" + encodeURIComponent(apiKey);

  try {
    const response = await fetch(url, { method: "POST", body });
    if (!response.ok) {
      fail("elmah.io returned " + response.status + " " + response.statusText + " when creating the deployment.");
      return;
    }
    console.log("Created deployment " + version + " on elmah.io.");
  } catch (e) {
    fail("Could not notify elmah.io: " + (e && e.message ? e.message : e));
  }
}

run();
