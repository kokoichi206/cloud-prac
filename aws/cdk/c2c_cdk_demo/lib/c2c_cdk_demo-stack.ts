import * as cdk from "aws-cdk-lib";
import { Construct } from "constructs";
// import * as sqs from 'aws-cdk-lib/aws-sqs';
import * as ec2 from "aws-cdk-lib/aws-ec2";

export class C2CCdkDemoStack extends cdk.Stack {
    constructor(scope: Construct, id: string, props?: cdk.StackProps) {
        super(scope, id, props);

        // The code that defines your stack goes here

        // example resource
        // const queue = new sqs.Queue(this, 'C2CCdkDemoQueue', {
        //   visibilityTimeout: cdk.Duration.seconds(300)
        // });

        const instanceIds = [];

        const instances = instanceIds.map((id) =>
            ec2.Instance.fromInstanceId(this, `Instance-${id}`, id)
        );

        const stopInstances = new ec2.CfnInstanceStopProps({
            instanceIds: instanceIds,
            force: false,
        });

        const startInstances = new ec2.CfnInstanceStartProps({
            instanceIds: instanceIds,
            additionalInfo: "",
            dryRun: false,
        });
    }
}
